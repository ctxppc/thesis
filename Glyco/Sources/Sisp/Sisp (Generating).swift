// Glyco © 2021 Constantino Tsarouhas

import Foundation

extension Sisp {
	
	/// Returns a serialised representation of `self`.
	public func serialised() -> String {
		lexemes().lazy
			.map(\.description)
			.joined(separator: " ")
	}
	
	/// Returns the lexemes representing `self`.
	func lexemes() -> [SispLexeme] {
		switch self {
			
			case .integer(let value):
			return [.integer(value)]
			
			case .string(let value):
			return [.lexeme(forLiteral: value)]
			
			case .list(let elements):
			return elements.flatMap { $0.lexemes() }
			
			case .structure(type: let type, children: let children):
			return [.lexeme(forLiteral: type), .leadingParenthesis]
				+ children.flatMap { [.lexeme(forLabel: $0.0)] + $0.1.lexemes() + [.separator] }
				+ [.trailingParenthesis]
			
		}
	}
	
}
