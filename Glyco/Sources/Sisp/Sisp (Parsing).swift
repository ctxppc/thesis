// Glyco © 2021 Constantino Tsarouhas

import Foundation

extension Sisp {
	
	/// Parses a Sisp value from given lexemes.
	public init(from serialised: String) throws {
		try self.init(from: Lexeme.lexemes(from: serialised)[...])
	}
	
	/// Parses a Sisp value from given lexemes.
	init<Lexemes : RandomAccessCollection>(from lexemes: Lexemes) throws where Lexemes.Element == Lexeme, Lexemes.SubSequence == Lexemes {
		var lexemes = lexemes
		self = try Self.parseValueOrList(from: &lexemes)
		if let remainingLexeme = lexemes.first {	// ensure we've reached end of stream
			throw ParsingError.unexpectedLexeme(remainingLexeme)
		}
	}
	
	/// Parses zero or more values encoded in `lexemes` until no more values can be parsed.
	///
	/// Any succesfully parsed values are removed from `lexemes`.
	///
	/// - Returns: If exactly one value is parsed, the parsed value. Otherwise, a list of zero, two, or more values.
	private static func parseValueOrList<C>(from lexemes: inout Lexemes<C>) throws -> Self {
		
		var values = [Sisp]()
		while let value = try parseValue(from: &lexemes) {
			values.append(value)
		}
		
		if let value = values.first, values.count == 1 {
			return value
		} else {
			return .list(values)
		}
		
	}
	
	/// Parses a value encoded in `lexemes`, returning `nil` if the leading lexeme doesn't indicate the begin of a value.
	///
	/// If a value is successfully parsed, it is removed from `lexemes`, otherwise `lexemes` remains unchanged.
	///
	/// - Returns: The parsed value, or `nil` if the leading lexeme doesn't indicate the begin of a value.
	private static func parseValue<C>(from lexemes: inout Lexemes<C>) throws -> Self? {
		let originalLexemes = lexemes
		switch lexemes.popFirst() {
			
			case .integer(let value)?:
			return .integer(value)
			
			case .word(let value)?, .quotedString(let value)?:
			if let children = try parseStructureChildren(from: &lexemes) {
				return .structure(type: value, children: children)
			} else {
				return .string(value)
			}
			
			case nil, .leadingParenthesis?, .trailingParenthesis?, .separator?, .label?, .quotedLabel?:
			lexemes = originalLexemes	// undo lexeme consumption
			return nil
			
		}
	}
	
	/// Parses the children of a structure encoded in `lexemes` between a leading and a trailing parenthesis, returning `nil` if `lexemes` doesn't start with a leading parenthesis.
	///
	/// Any successfully parsed children are removed from `lexemes`.
	///
	/// - Returns: The parsed children, keyed by label, or `nil` if `lexemes` doesn't start with a leading parenthesis.
	private static func parseStructureChildren<C>(from lexemes: inout Lexemes<C>) throws -> StructureChildren? {
		
		guard lexemes.first == .leadingParenthesis else { return nil }
		lexemes.removeFirst()
		
		var labelledChildren = StructureChildren()
		var index = 0
		while let (name, child) = try parseStructureChild(from: &lexemes, childIndex: index) {
			let previous = labelledChildren.updateValue(child, forKey: name)
			guard previous == nil else { throw ParsingError.duplicateLabel(name) }
			index += 1
		}
		
		guard lexemes.popFirst() == .trailingParenthesis else { throw ParsingError.expectedTrailingParenthesis }
		
		return labelledChildren
		
	}
	
	/// Parses a child of a structure encoded in `lexemes`, returning `nil` if `lexemes` starts with a trailing parenthesis.
	///
	/// If a child is successfully parsed, it is removed from `lexemes` as well as up to one trailing separator; otherwise, `lexemes` remains unchanged.
	///
	/// - Returns: The structure child, or `nil` if the leading lexeme starts with a trailing parenthesis.
	private static func parseStructureChild<C>(from lexemes: inout Lexemes<C>, childIndex: Int) throws -> StructureChild? {
		
		let label: Label
		switch lexemes.first {
			
			case .label(let l)?, .quotedLabel(let l)?:
			label = l
			lexemes.removeFirst()
			
			case .trailingParenthesis:
			return nil
			
			default:
			label = .numbered(childIndex)
			
		}
		
		let child = try Self.parseValueOrList(from: &lexemes)
		
		if lexemes.first == .separator {
			lexemes.removeFirst()
		}
		
		return (label, child)
		
	}
	
	private typealias Lexemes<C : RandomAccessCollection> = C where C.Element == Lexeme, C.SubSequence == C
	
	enum ParsingError : LocalizedError {
		
		/// An error indicating that given lexeme is not expected.
		case unexpectedLexeme(Lexeme)
		
		/// An error indicating that a structure contains two children with the same label.
		case duplicateLabel(Label)
		
		/// An error indicating that a trailing parenthesis is expected.
		case expectedTrailingParenthesis
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .unexpectedLexeme(let lexeme):	return "“\(lexeme)” is not expected."
				case .duplicateLabel(let name):		return "More than one child is labelled “\(name)”."
				case .expectedTrailingParenthesis:	return "A trailing parenthesis is expected."
			}
		}
		
	}
	
}
