// Sisp © 2021–2022 Constantino Tsarouhas

import DepthKit
import Foundation
import PatternKit

/// A lexeme in a Sisp.
enum Lexeme : Equatable {
	
	/// A leading parenthesis lexeme, i.e., `(`.
	case leadingParenthesis
	private static let leadingParenthesisPattern: Literal<Substring> = "("
	
	/// A trailing parenthesis lexeme, i.e., `)`.
	case trailingParenthesis
	private static let trailingParenthesisPattern: Literal<Substring> = ")"
	
	/// A separator lexeme, i.e., `,`.
	case separator
	private static let separatorPattern: Literal<Substring> = ","
	
	/// A lexeme specifying an integer.
	case integer(Int)
	private static let integerPattern = "-"/? • ("0"..."9")+
	
	/// A lexeme specifying a label for a child, e.g., `destination:`.
	///
	/// - Parameter 1: The label, excluding `:` marker.
	case label(Label)
	private static let labelPattern = labelToken • ":"
	private static let labelToken = Token(identifierPattern)
	
	/// A lexeme specifying a quoted label for a child, e.g., `"the destination":`.
	///
	/// - Parameter 1: The label, *excluding* the `:` marker, bounding quotation marks, and escape characters.
	case quotedLabel(Label)
	private static let quotedLabelPattern = #"""# • quotedLabelToken • #"""# • ":"
	private static let quotedLabelToken = Token(literalCharacterPattern*)
	
	/// A lexeme specifying a word, e.g., `sequence`.
	///
	/// - Parameter 1: The word.
	case word(String)
	private static let wordPattern = identifierPattern
	
	/// A lexeme specifying a quoted string, e.g., `"Five Guys"`.
	///
	/// - Parameter 1: The string, *excluding* bounding quotation marks and escape characters.
	case quotedString(String)
	private static let quotedStringPattern = #"""# • quotedStringToken • #"""#
	private static let quotedStringToken = Token(literalCharacterPattern*)
	
	/// A pattern matching identifiers.
	private static let identifierPattern = (CharacterSet.letters | "_") • (CharacterSet.alphanumerics | "_")*
	
	/// The characters that cannot appear in a string literal.
	private static let illegalLiteralCharacters = CharacterSet.illegalCharacters | .controlCharacters
	
	/// The characters that can appear in a string literal with no need for escaping.
	private static let literalCharactersNotRequiringEscape = (illegalLiteralCharacters | #"""#).inverted
	
	/// A pattern matching an escaped or valid nonescaped character in a literal.
	private static let literalCharacterPattern = literalCharactersNotRequiringEscape | Literal(#""""#)
	
	/// Extracts all lexemes from `stream`.
	///
	/// - Parameter stream: The string from which to extract the first lexeme.
	///
	/// - Returns: The lexemes extracted from `stream`.
	static func lexemes(from stream: String) throws -> [Self] {
		var stream = stream[...]
		var lexemes = [Self]()
		while let lexeme = try Self(from: &stream) {	// sequence(state:next:) doesn't support throwing successor function
			lexemes.append(lexeme)
		}
		return lexemes
	}
	
	/// Extracts the first lexeme from `stream`, skipping over any whitespace.
	///
	/// This initialiser removes any leading whitespace from `stream`. If a lexeme is extracted successfully, it is also removed from `stream`.
	///
	/// - Parameter stream: The string from which to extract the first lexeme.
	///
	/// - Returns: `nil` if `stream` is empty or contains only whitespace.
	init?(from stream: inout Substring) throws {
		
		stream = stream.drop(while: \.isWhitespace)
		
		guard !stream.isEmpty else { return nil }
		
		func extractMatch<P : Pattern>(using pattern: P, lexeme: (Match<Substring>) throws -> Self) rethrows -> Self? where P.Subject == Substring {
			let match = pattern
				.forwardMatches(enteringFrom: Match(over: stream, direction: .forward))
				.first
			guard let match = match else { return nil }
			let lex = try lexeme(match)	// do not truncate stream if an error is thrown here
			stream = stream[match.inputPosition...]
			return lex
		}
		
		let lexeme = try extractMatch(using: Self.leadingParenthesisPattern) { _ in .leadingParenthesis }
			?? extractMatch(using: Self.trailingParenthesisPattern) { _ in .trailingParenthesis }
			?? extractMatch(using: Self.separatorPattern) { _ in .separator }
			?? extractMatch(using:Self.quotedLabelPattern) { match in
				let value = match.captures(for: Self.quotedLabelToken).first !! "Expected capture"
				return .quotedLabel(.init(fromEscapedRawValue: value))
			} ?? extractMatch(using: Self.quotedStringPattern) { match in
				let value = match.captures(for: Self.quotedStringToken).first !! "Expected capture"
				return .quotedString(.init(fromEscaped: value))
			} ?? extractMatch(using: Self.integerPattern) { match in
				let string = match.matchedElements(direction: .forward)
				guard let integer = Int(string) else { throw LexingError.unrepresentableIntegerLiteral(literal: string, unlexedPortion: stream) }
				return .integer(integer)
			} ?? extractMatch(using: Self.labelPattern) { match in
				let label = match.captures(for: Self.labelToken).first !! "Expected capture"
				return .label(.init(rawValue: label))
			} ?? extractMatch(using: Self.wordPattern) { .word(.init($0.matchedElements(direction: .forward))) }
		
		guard let lexeme = lexeme else {
			throw LexingError.invalidCharacter(unlexedPortion: stream)
		}
		self = lexeme
		
	}
	
	enum LexingError : LocalizedError {
		
		/// An error indicating that an integer literal cannot be represented as an integer.
		case unrepresentableIntegerLiteral(literal: Substring, unlexedPortion: Substring)
		
		/// An error indicating that the stream contains an invalid character.
		case invalidCharacter(unlexedPortion: Substring)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				
				case .unrepresentableIntegerLiteral(literal: let literal, unlexedPortion: let unlexedPortion):
				return "The integer literal “\(literal)” cannot be represented as an integer. Remaining portion: “\(unlexedPortion)”."
					
				case .invalidCharacter(unlexedPortion: let unlexedPortion):
				return "Invalid character found, starting from “\(unlexedPortion)”."
			}
		}
		
	}
	
	/// Returns a lexeme that can represent `string`.
	static func lexeme(for string: String) -> Self {
		wordPattern.hasMatches(over: string[...])
			? .word(string)
			: .quotedString(string)
	}
	
	/// Returns a lexeme that can represent `label`, or `nil` if `label` isn't represented by a lexeme.
	static func lexeme(for label: Label) -> Self? {
		switch label {
			
			case .named(let name):
			return wordPattern.hasMatches(over: name[...])
				? .label(label)
				: .quotedLabel(label)
			
			case .numbered:
			return nil
			
		}
	}
	
}

extension Lexeme : CustomStringConvertible {
	var description: String {
		switch self {
			case .leadingParenthesis:		return "("
			case .trailingParenthesis:		return ")"
			case .separator:				return ","
			case .integer(let value):		return "\(value)"
			case .label(let label):			return "\(label):"
			case .quotedLabel(let label):	return #""\#(label.escapedRawValue)":"#
			case .word(let value):			return value
			case .quotedString(let string):	return #""\#(string.escaped)""#
		}
	}
}

private extension String {
	
	/// Copies `escaped` but with escaped quotation marks replaced by nonescaped quotation marks.
	init<S : StringProtocol>(fromEscaped escaped: S) {
		self = escaped.replacingOccurrences(of: #""""#, with: #"""#)
	}
	
}

private extension StringProtocol {
	
	/// `self`, but with quotation marks replaced by escaped quotation marks.
	var escaped: String {
		replacingOccurrences(of: #"""#, with: #""""#)
	}
	
}

private extension Label {
	
	init<S : StringProtocol>(fromEscapedRawValue escapedRawValue: S) {
		self.init(rawValue: .init(fromEscaped: escapedRawValue))
	}
	
	var escapedRawValue: String {
		rawValue.escaped
	}
	
}
