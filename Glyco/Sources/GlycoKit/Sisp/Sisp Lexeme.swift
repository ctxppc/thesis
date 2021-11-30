// Glyco © 2021 Constantino Tsarouhas

import PatternKit
import Foundation

/// A lexeme in a Sisp.
enum SispLexeme {
	
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
	private static let attributeLabelPattern = Token(identifierPattern) • ":"
	
	/// A lexeme specifying a type name, e.g., `sequence`.
	///
	/// - Parameter 1: The type name.
	case typeName(String)
	private static let typeNamePattern = Token(identifierPattern)
	
	/// A pattern matching identifiers.
	private static let identifierPattern = CharacterSet.letters • CharacterSet.alphanumerics+
	
	/// Extracts the first lexeme from `stream`.
	///
	/// This initialiser truncates `stream` when a lexeme has been succesfully truncated.
	///
	/// - Parameter stream: The string from which to extract the first lexeme.
	init(from stream: inout Substring) throws {
		
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
				guard let integer = Int(string) else { throw LexingError.unrepresentableIntegerLiteral(string) }
				return .integer(integer)
			}
		
		TODO.unimplemented
		
	}
	
	enum LexingError : LocalizedError {
		
		/// An error indicating that an integer literal cannot be represented as an integer.
		case unrepresentableIntegerLiteral(Substring)
		
		var errorDescription: String? {
			switch self {
				case .unrepresentableIntegerLiteral(let literal):
				return "The integer literal “\(literal)” cannot be represented as an integer."
			}
		}
		
	}
	
}
