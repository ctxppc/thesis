// Sisp © 2021–2022 Constantino Tsarouhas

import Algorithms
import DepthKit
import Foundation

extension Sisp : SingleLineSerialisable {
	
	public func serialiseOnCurrentLine(into serialisation: inout Serialisation<Lexeme>) throws {
		
		func serialise(_ child: StructureChild) throws {
			if let label = Lexeme.lexeme(for: child.0) {
				serialisation.write(label)
				serialisation.writeSpace()
			}
			try serialisation.serialiseOnCurrentLine(child.1)
		}
		
		switch self {
			
			case .integer(let value):
			serialisation.write(.integer(value))
			
			case .string(let string):
			serialisation.write(.lexeme(for: string))
			
			case .list(let elements):
			guard let (head, last) = elements.splittingLast() else { return }
			for element in head {
				try serialisation.serialiseOnCurrentLine(element)
				serialisation.writeSpace()
			}
			try serialisation.serialiseOnCurrentLine(last)
			
			case .structure(let type, let children):
			do {
				
				if let type = type {
					serialisation.write(.lexeme(for: type))
				}
				
				serialisation.write(.leadingParenthesis)
				
				guard let (head, last) = children.elements.splittingLast() else { return }
				for element in head {
					try serialise(element)
					serialisation.write(.separator)
					serialisation.writeSpace()
				}
				try serialise(last)
				
				serialisation.write(.trailingParenthesis)
				
			}
			
		}
		
	}
	
	public func serialiseOverMultipleLines(into serialisation: inout Serialisation<Lexeme>) {
		
		func serialise(_ value: Sisp) {
			do {
				try serialisation.serialiseOnCurrentLine(value)
			} catch {
				serialisation.serialiseOverMultipleLines(value)
			}
		}
		
		func serialise(_ child: StructureChild) {
			if let label = Lexeme.lexeme(for: child.0) {
				serialisation.write(label)
				serialisation.writeSpace()
			}
			serialise(child.1)
		}
		
		switch self {
			
			case .integer(let value):
			serialisation.write(.integer(value))
			
			case .string(let string):
			serialisation.write(.lexeme(for: string))
			
			case .list(let elements):
			guard let (head, last) = elements.splittingLast() else { return }
			for element in head {
				serialise(element)
				serialisation.beginLine()
			}
			serialise(last)
			
			case .structure(let type, let children):
			do {
				
				if let type = type {
					serialisation.write(.lexeme(for: type))
				}

				serialisation.write(.leadingParenthesis)
				serialisation.beginIndentedLine()

				guard let (head, last) = children.elements.splittingLast() else { return }
				for element in head {
					serialise(element)
					serialisation.write(.separator)
					serialisation.beginLine()
				}
				serialise(last)
				
				serialisation.beginOutdentedLine()
				serialisation.write(.trailingParenthesis)
				
			}
			
		}
		
	}
	
}
