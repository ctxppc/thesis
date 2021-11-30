// Glyco © 2021 Constantino Tsarouhas

import DepthKit
import Foundation
import PatternKit

/// A lexeme in a Sisp.
enum SispLexeme : Equatable {
	
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
	
	/// A lexeme specifying an attribute label and terminating with the label terminator `:`, e.g., `destination:`.
	///
	/// - Parameter 1: The attribute name (excluding terminator).
	case attributeLabel(String)
	private static let attributeLabelPattern = attributeLabelToken • ":"
	private static let attributeLabelToken = Token(identifierPattern)
	
	/// A lexeme specifying a type name, e.g., `sequence`.
	///
	/// - Parameter 1: The type name.
	case typeName(String)
	private static let typeNamePattern = identifierPattern
	
	/// A pattern matching identifiers.
	private static let identifierPattern = CharacterSet.letters • CharacterSet.alphanumerics+
	
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
		let streamPosition = stream.startIndex
		
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
			?? extractMatch(using: Self.integerPattern) { match in
				let string = match.matchedElements(direction: .forward)
				guard let integer = Int(string) else { throw LexingError.unrepresentableIntegerLiteral(literal: string, position: streamPosition) }
				return .integer(integer)
			} ?? extractMatch(using: Self.attributeLabelPattern) { match in
				let label = match.captures(for: Self.attributeLabelToken).first !! "Expected capture"
				return .attributeLabel(.init(label))
			} ?? extractMatch(using: Self.typeNamePattern) { .typeName(.init($0.matchedElements(direction: .forward))) }
		
		guard let lexeme = lexeme else { throw LexingError.invalidCharacter(position: streamPosition) }
		self = lexeme
		
	}
	
	enum LexingError : LocalizedError {
		
		/// An error indicating that an integer literal cannot be represented as an integer.
		case unrepresentableIntegerLiteral(literal: Substring, position: String.Index)
		
		/// An error indicating that the stream contains an invalid character.
		case invalidCharacter(position: String.Index)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				
				case .unrepresentableIntegerLiteral(literal: let literal, position: let position):
				return "The integer literal “\(literal)” at \(position) cannot be represented as an integer."
					
				case .invalidCharacter(position: let position):
				return "Invalid character found at \(position)"
			}
		}
		
	}
	
}
