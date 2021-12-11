// Glyco © 2021 Constantino Tsarouhas

import Collections
import Foundation
import PatternKit

/// A Sisp value, which can be an integer, a string, a list of Sisp values, or a typed structure with named children.
public enum Sisp : Hashable {
	
	/// An integer.
	///
	/// An integer is serialised as a decimal literal, e.g., `-13`, `5`, and `+5`.
	case integer(Int)
	
	/// A string.
	///
	/// A string is serialised using a `word` lexeme if possible, and using a `quotedString` otherwise.
	case string(String)
	
	/// A list of values.
	///
	/// A list is serialised as:
	///
	///     child_1 child_2 … child_n
	///
	/// Since there is no additional syntax associated with the list construct, a list of zero elements is serialised as zero lexemes, and a list of one element is serialised using the child's serialisation only. This is an intentional decision to simplify notation. Decoders must take care to accommodate for this.
	case list([Self])
	
	/// A structure of type `type` containing children `children`.
	///
	/// A structure is serialised as:
	///
	///     type ( label_1: child_1 , label_2: child_2 … , label_n: child_n )
	///
	/// for each `label_i`–`child_i` pair in `children`. Each `label_i:` is either omitted (if `.numbered`), a label (if representable), or a quoted label (otherwise). For example:
	///
	///     car(colour: blue, size: "quite small", 2007)
	case structure(type: String, children: StructureChildren)
	public typealias StructureChildren = OrderedDictionary<Label, Self>
	public typealias StructureChild = (Label, Self)
	
	/// A value describing the type of value contained in `self`.
	var typeDescription: String {
		switch self {
			case .integer:									return "Integer"
			case .string:									return "String"
			case .list:										return "List"
			case .structure(type: let type, children: _):	return "Structure of type “\(type)”"
		}
	}
	
}

extension Sisp : ExpressibleByIntegerLiteral {
	public init(integerLiteral value: Int) {
		self = .integer(value)
	}
}

extension Sisp : ExpressibleByStringLiteral {
	public init(stringLiteral value: String) {
		self = .string(value)
	}
}

extension Sisp : ExpressibleByArrayLiteral {
	public init(arrayLiteral elements: Sisp...) {
		self = .list(elements)
	}
}
