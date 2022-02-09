// Sisp © 2021–2022 Constantino Tsarouhas

import Algorithms
import DepthKit
import Foundation

extension Sisp {
	
	/// Returns a serialised representation of `self`.
	public func serialised() -> String {
		var serialisation = Serialisation()
		serialise(into: &serialisation)
		return serialisation.serialisation()
	}
	
	/// Serialises `self` to `serialisation`.
	private func serialise(into serialisation: inout Serialisation) {
		
		func serialiseList(_ elements: [Sisp]) {
			guard let (head, last) = elements.splittingLast() else { return }
			let multiline = hasMultilineSerialisation()
			for element in head {
				element.serialise(into: &serialisation)
				multiline ? serialisation.beginLine() : serialisation.writeSpace()
			}
			last.serialise(into: &serialisation)
		}
		
		func serialise(_ child: StructureChild) {
			if let label = Lexeme.lexeme(for: child.0) {
				serialisation.write(label)
				serialisation.writeSpace()
			}
			child.1.serialise(into: &serialisation)
		}
		
		func serialiseStructure(type: String?, children: StructureChildren) {
			
			if let type = type {
				serialisation.write(.lexeme(for: type))
			}
			
			serialisation.write(.leadingParenthesis)
			
			if let (head, last) = children.elements.splittingLast() {
				if hasMultilineSerialisation() {
					
					serialisation.beginIndentedLine()
					
					for child in head {
						serialise(child)
						serialisation.write(.separator)
						serialisation.beginLine()
					}
					serialise(last)
					
					serialisation.beginOutdentedLine()
					
				} else {
					for child in head {
						serialise(child)
						serialisation.write(.separator)
						serialisation.writeSpace()
					}
					serialise(last)
				}
			}
			
			serialisation.write(.trailingParenthesis)
			
		}
		
		switch self {
			
			case .integer(let value):
			serialisation.write(.integer(value))
			
			case .string(let value):
			serialisation.write(.lexeme(for: value))
			
			case .list(let elements):
			serialiseList(elements)
			
			case .structure(type: let type, children: let children):
			serialiseStructure(type: type, children: children)
			
		}
		
	}
	
	private struct Serialisation {
		
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
		mutating func write(_ lexeme: Lexeme) {
			currentLine.text += "\(lexeme)"
		}
		
		/// Writes a horizontal space character in the serialisation.
		mutating func writeSpace() {
			currentLine.text += " "
		}
		
		/// Begins a line with the same indentation level.
		mutating func beginLine() {
			previousLines.append(currentLine)
			currentLine.text = ""
		}
		
		/// Begins a line with a deeper indentation level.
		mutating func beginIndentedLine() {
			beginLine()
			currentLine.indentationLevel += 1
		}
		
		/// Begins a line with a less deep indentation level.
		mutating func beginOutdentedLine() {
			beginLine()
			currentLine.indentationLevel -= 1
		}
		
		/// Returns the serialisation.
		///
		/// - Requires: Every `indent()` is balanced with an `outdent()`.
		func serialisation(indentation: String = "\t") -> String {
			chain(previousLines, [currentLine])
				.lazy
				.map { $0.stringRepresentation(depth: 0, indentation: indentation) }
				.joined(separator: "\n")
		}
		
	}
	
	/// Returns a Boolean value indicating whether `self` is serialised to more than one line.
	private func hasMultilineSerialisation() -> Bool {
		switch self {
			case .integer, .string:						return false
			case .list(let elements):					return elements.count >= 3 || elements.contains(where: { $0.hasMultilineSerialisation() })
			case .structure(type: _, children: let c):	return c.count >= 3 || c.values.contains(where: { $0.hasMultilineSerialisation() })
		}
	}
	
}
