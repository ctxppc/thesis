// Glyco © 2021 Constantino Tsarouhas

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
	/// A list is serialised as its elements' serialisations, separated by whitespace. Since there is no additional syntax, a list of zero elements is serialised as zero lexemes, and a list of one element is serialised using the child's serialisation only. This is an intentional decision to simplify notation. Decoders must take care to accommodate for this.
	case list([Self])
	
	/// A structure of type `type` containing labelled children `children`.
	///
	/// A structure is serialised as its `type` using a `word` (if possible) or `quotedString` lexeme (otherwise); a leading parenthesis lexeme; its labelled children, each separated by a separator lexeme; and finally a trailing parenthesis. Each labelled child is serialised using a label lexeme (if possible) or quoted label lexeme (otherwise) for the label followed by the child's serialisation. For example, `car(colour: blue, size: "very large")`.
	case structure(type: String, children: [String : Self])
	
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
