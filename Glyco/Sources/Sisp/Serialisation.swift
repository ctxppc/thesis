// Sisp © 2021–2022 Constantino Tsarouhas

import Algorithms

/// A value representing a serialised value.
public struct Serialisation<Lexeme> {
	
	/// Creates an empty serialisation.
	public init(indentation: String, maxLineLength: Int) {
		self.indentation = indentation
		self.maxLineLength = maxLineLength
		apparentIndentationSize = indentation
			.map { $0 == "\t" ? Self.apparentTabSize : 1 }
			.reduce(0, +)
	}
	
	/// The string used for each level of indentation.
	public let indentation: String
	
	/// The maximum line length, on a best-effort basis.
	///
	/// The serialisation attempts to keep line lengths below the limit by reserialising values over multiple lines whenever the limit is exceeded.
	public let maxLineLength: Int
	
	/// The (apparent) size of `indentation`.
	private let apparentIndentationSize: Int
	
	/// The apparent size of the tab character, used in computing the line length.
	private static var apparentTabSize: Int { 4 }
	
	/// Serialises given value at the current position on the current line.
	///
	/// `self` does not change if an error is thrown and can therefore be used for a new serialisation attempt.
	///
	/// - Throws: `SerialisationError.singleLineSerialisationNotSupported` or `.lineLimitExceeded`.
	public mutating func serialiseOnCurrentLine<S : SingleLineSerialisable>(_ serialisable: S) throws where S.LexemeType == Lexeme {
		
		// Checkpoint.
		var copy = self
		
		// Attempt serialisation.
		try serialisable.serialiseOnCurrentLine(into: &copy)
		
		// Check line length.
		if (currentLine.indentationLevel * apparentIndentationSize) + currentLine.text.count > maxLineLength {
			throw SerialisationError.lineLimitExceeded
		}
		
		// No errors thrown. Commit.
		self = copy
		
	}
	
	/// Serialises given value into at the current position, preferring to split the serialisation over multiple lines.
	public mutating func serialiseOverMultipleLines<S : Serialisable>(_ serialisable: S) where S.LexemeType == Lexeme {
		serialisable.serialiseOverMultipleLines(into: &self)
	}
	
	/// The previous lines.
	private var previousLines = [Line]()
	
	/// The current line.
	private var currentLine = Line()
	
	private struct Line {
		
		/// The line's indentation level.
		var indentationLevel = 0 {
			willSet { precondition(indentationLevel >= 0, "Indentation level must be nonnegative") }
		}
		
		/// The line's text, without indentation.
		var text: String = ""
		
		/// Returns the string representation of `self`.
		func stringRepresentation(depth: Int, indentation: String) -> String {
			let indentation = (0..<(indentationLevel + depth))
				.map { _ in indentation }
				.joined()
			return "\(indentation)\(text)"
		}
		
	}
	
	/// Writes a lexeme in the serialisation.
	///
	/// - Parameters:
	///   - lexeme: The lexeme to write, or `nil` to write no lexeme.
	///   - trailingWhitespace: The kind of whitespace that is required after the lexeme, or `nil` if no whitespace is required.
	public mutating func write(_ lexeme: Lexeme) {
		currentLine.text += "\(lexeme)"
	}
	
	/// Writes a horizontal space character in the serialisation.
	public mutating func writeSpace() {
		currentLine.text += " "
	}
	
	/// Begins a line with the same indentation level.
	public mutating func beginLine() {
		previousLines.append(currentLine)
		currentLine.text = ""
	}
	
	/// Begins a line with a deeper indentation level.
	public mutating func beginIndentedLine() {
		beginLine()
		currentLine.indentationLevel += 1
	}
	
	/// Begins a line with a less deep indentation level.
	public mutating func beginOutdentedLine() {
		beginLine()
		currentLine.indentationLevel -= 1
	}
	
	/// Returns the serialisation.
	///
	/// - Requires: The indentation level is 0.
	func serialisation() -> String {
		chain(previousLines, [currentLine])
			.lazy
			.map { $0.stringRepresentation(depth: 0, indentation: indentation) }
			.joined(separator: "\n")
	}
	
}

/// A value that can serialise itself.
public protocol Serialisable {
	
	/// Serialises `self` into `serialisation`, preferring to split the serialisation over multiple lines.
	///
	/// If `self` serialises subvalues, this method should attempt to serialise itself over multiple lines and its subvalues on a single line (by using `serialiseOnCurrentLine(_:)`). If single-line serialisation fails, this method should revert to multiline serialisation.
	func serialiseOverMultipleLines(into serialisation: inout Serialisation<LexemeType>)
	associatedtype LexemeType
	
}

/// A value that can serialise itself on a single line.
public protocol SingleLineSerialisable : Serialisable {
	
	/// Serialises `self` into `serialisation` without writing any newlines.
	///
	/// - Invariant: This method does not invoke `writeNewline()`, `writeIndentedNewline()`, or `writeOutdentedNewline()`.
	///
	/// - Throws: `SerialisationError.requiresMultipleLines` if `self` requires more than one line.
	func serialiseOnCurrentLine(into serialisation: inout Serialisation<LexemeType>) throws
	
}

extension Serialisable {
	
	/// Returns a serialised representation of `self`.
	public func serialised(indentation: String = "\t", maxLineLength: Int = 120) -> String {
		var serialisation = Serialisation<LexemeType>(indentation: indentation, maxLineLength: maxLineLength)
		serialisation.serialiseOverMultipleLines(self)
		return serialisation.serialisation()
	}
	
}

extension SingleLineSerialisable {
	
	/// Returns a serialised representation of `self`.
	public func serialised(indentation: String = "\t", maxLineLength: Int = 120) -> String {
		var serialisation = Serialisation<LexemeType>(indentation: indentation, maxLineLength: maxLineLength)
		do {
			try serialisation.serialiseOnCurrentLine(self)
		} catch {
			serialisation.serialiseOverMultipleLines(self)
		}
		return serialisation.serialisation()
	}
	
}

public enum SerialisationError : Error {
	
	/// An error indicating that a value cannot be serialised on a single line due to a subvalue not support single-line serialisation.
	///
	/// `serialiseOverMultipleLines(_:)` must be used.
	case singleLineSerialisationNotSupported
	
	/// An error indicating that a value cannot be serialised on a single line due to a line limit has been exceeded.
	///
	/// `serialiseOverMultipleLines(_:)` must be used.
	case lineLimitExceeded
	
}
