// Glyco © 2021 Constantino Tsarouhas

import Algorithms
import Foundation

extension Sisp {
	
	/// Returns a serialised representation of `self`.
	public func serialised() -> String {
		var generator = Generator()
		generate(into: &generator)
		return generator.serialisation()
	}
	
	/// Generates serialised output representing `self` in `generator`.
	private func generate(into generator: inout Generator) {
		switch self {
			
			case .integer(let value):
			generator.write(.integer(value), trailingWhitespace: false)
			
			case .string(let value):
			generator.write(.lexeme(forLiteral: value), trailingWhitespace: false)
			
			case .list(let elements):
			generator.indent()
			for element in elements {
				generator.writeNewline()
				element.generate(into: &generator)
			}
			generator.outdent()
			generator.writeNewline()
			
			case .structure(type: let type, children: let children):
			generator.write(.lexeme(forLiteral: type), trailingWhitespace: false)
			generator.write(.leadingParenthesis, trailingWhitespace: false)
			var seenFirst = false
			for (label, child) in children {
				if seenFirst {
					generator.write(.separator, trailingWhitespace: true)
				} else {
					seenFirst = true
				}
				generator.write(.lexeme(forLabel: label), trailingWhitespace: true)
				child.generate(into: &generator)
			}
			generator.write(.trailingParenthesis, trailingWhitespace: false)
			
		}
		
		
	}
	
	private struct Generator {
		
		/// The serialised Sisp
		private var serialised = ""
		
		/// The level of indentation.
		private var indentation = 0
		
		/// A Boolean value indicating whether the previously outputted lexeme needs whitespace after it.
		private var previousLexemeNeedsTrailingWhitespace = false
		
		/// Writes a lexeme in the serialisation.
		///
		/// - Parameters:
		///   - lexeme: The lexeme to write.
		///   - trailingWhitespace: `true` if `lexeme` needs (horizontal or vertical) whitespace after it in the serialisation; `false` otherwise.
		mutating func write(_ lexeme: SispLexeme, trailingWhitespace: Bool) {
			ensureTrailingWhitespaceIfNeeded()
			serialised += "\(lexeme)"
			previousLexemeNeedsTrailingWhitespace = trailingWhitespace
		}
		
		/// Writes a newline in the serialisation.
		mutating func writeNewline() {
			serialised += "\n" + "\t".cycled(times: indentation)
			previousLexemeNeedsTrailingWhitespace = false
		}
		
		/// Increases indentation.
		mutating func indent() {
			indentation += 1
		}
		
		/// Decreases indentation.
		///
		/// - Requires: `indent()` has been invoked more on `self` than `outdent()` has.
		mutating func outdent() {
			precondition(indentation > 0, "Cannot remove more indentation")
			indentation -= 1
		}
		
		/// Ensures that the previous lexeme has trailing whitespace in the serialisation, if necessary.
		private mutating func ensureTrailingWhitespaceIfNeeded() {
			guard previousLexemeNeedsTrailingWhitespace else { return }
			serialised += " "
			previousLexemeNeedsTrailingWhitespace = false
		}
		
		/// Returns the serialisation.
		///
		/// - Requires: Every `indent()` is balanced with an `outdent()`.
		mutating func serialisation() -> String {
			precondition(indentation == 0, "Cannot finalise serialisation with indentation")
			ensureTrailingWhitespaceIfNeeded()
			return serialised
		}
		
	}
	
}
