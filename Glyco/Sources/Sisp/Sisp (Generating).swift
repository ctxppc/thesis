// Glyco © 2021 Constantino Tsarouhas

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
		
		func serialise(label: Label, child: Self, isMultilineStructure: Bool, isLast: Bool) {
			if isMultilineStructure {
				if child.hasMultilineSerialisation() {
					serialisation.write(.lexeme(for: label), then: .indentedNewline)
					child.serialise(into: &serialisation)
					if isLast {
						serialisation.write(.outdentedNewline)
					} else {
						serialisation.write(.separator, then: .outdentedNewline)
					}
				} else {
					serialisation.write(.lexeme(for: label), then: .spaceOrNewline)
					child.serialise(into: &serialisation)
					if isLast {
						serialisation.write(.newline())
					} else {
						serialisation.write(.separator, then: .newline())
					}
				}
			} else {
				serialisation.write(.lexeme(for: label), then: .spaceOrNewline)
				child.serialise(into: &serialisation)
				if !isLast {
					serialisation.write(.separator, then: .spaceOrNewline)
				}
			}
		}
		
		func serialiseLabelledChildren(_ children: LabelledChildren, isMultilineStructure: Bool) {
			guard let (children, (label, child)) = children.elements.splittingLast() else { return }
			for (label, child) in children {
				serialise(label: label, child: child, isMultilineStructure: isMultilineStructure, isLast: false)
			}
			serialise(label: label, child: child, isMultilineStructure: isMultilineStructure, isLast: true)
		}
		
		switch self {
			
			case .integer(let value):
			serialisation.write(.integer(value), then: nil)
			
			case .string(let value):
				serialisation.write(.lexeme(for: value), then: nil)
			
			case .list(let elements):
			guard let (elements, last) = elements.splittingLast() else { return }
			for element in elements {
				element.serialise(into: &serialisation)
				serialisation.write(.newline())
			}
			last.serialise(into: &serialisation)
			
			case .structure(type: let type, children: let children) where hasMultilineSerialisation():
				serialisation.write(.lexeme(for: type), then: nil)
			serialisation.write(.leadingParenthesis, then: nil)
			serialisation.write(.indentedNewline)
			serialiseLabelledChildren(children, isMultilineStructure: true)
			serialisation.write(.outdentedNewline)
			serialisation.write(.trailingParenthesis, then: nil)
			
			case .structure(type: let type, children: let children):
				serialisation.write(.lexeme(for: type), then: nil)
			serialisation.write(.leadingParenthesis, then: nil)
			serialiseLabelledChildren(children, isMultilineStructure: false)
			serialisation.write(.trailingParenthesis, then: nil)
			
		}
		
	}
	
	private struct Serialisation {
		
		/// The serialised representation.
		private var serialised = ""
		
		/// The level of indentation.
		private var indentation = 0 {
			willSet { precondition(indentation >= 0, "Indentation must be nonnegative") }
		}
		
		/// A value indicating what kind of whitespace is required after the last lexeme.
		private var requiredTrailingWhitespace: Whitespace?
		enum Whitespace {
			case spaceOrNewline
			case newline(indentationChange: Int = 0)
			static var indentedNewline: Self { .newline(indentationChange: 1) }
			static var outdentedNewline: Self { .newline(indentationChange: -1) }
		}
		
		/// Writes a lexeme in the serialisation.
		///
		/// - Parameters:
		///   - lexeme: The lexeme to write.
		///   - trailingWhitespace: The kind of whitespace that is required after the lexeme, or `nil` if no whitespace is required.
		mutating func write(_ lexeme: SispLexeme, then trailingWhitespace: Whitespace?) {
			
			switch requiredTrailingWhitespace {
				
				case nil:
				break
				
				case .spaceOrNewline?:
				serialised += " "
				requiredTrailingWhitespace = nil
				
				case .newline(indentationChange: let change)?:
				indentation += change
				serialised += "\n" + "\t".cycled(times: indentation)
				requiredTrailingWhitespace = nil
				
			}
			
			serialised += "\(lexeme)"
			if let whitespace = trailingWhitespace {
				write(whitespace)
			}
			
		}
		
		/// Writes whitespace in the serialisation.
		///
		/// To keep the serialisation trimmed and to avoid redundant whitespace, the whitespace is only effectively added just before the next lexeme is written.
		mutating func write(_ whitespace: Whitespace) {
			switch (requiredTrailingWhitespace, whitespace) {
				
				case (nil, _), (.spaceOrNewline, _):
				requiredTrailingWhitespace = whitespace
				
				case (.newline, .spaceOrNewline):
				break
				
				case (.newline(indentationChange: let d1), .newline(indentationChange: let d2)):
				requiredTrailingWhitespace = .newline(indentationChange: d1 + d2)
				
			}
		}
		
		/// Returns the serialisation.
		///
		/// - Requires: Every `indent()` is balanced with an `outdent()`.
		mutating func serialisation() -> String {
			precondition(indentation == 0, "Cannot finalise serialisation with indentation")
			return serialised
		}
		
	}
	
	/// Returns a Boolean value indicating whether `self` is serialised to more than one line.
	private func hasMultilineSerialisation() -> Bool {
		switch self {
			case .integer, .string:						return false
			case .list(let elements):					return elements.count >= 2
			case .structure(type: _, children: let c):	return c.values.contains(where: { $0.hasMultilineSerialisation() })
		}
	}
	
}
