// Glyco © 2021 Constantino Tsarouhas

/// A Sisp value, which can be an integer, a string, a list of Sisp values, or a typed structure with named children.
///
/// Lists are encoded in Sisp by juxtaposition, separated by whitespace. This causes an ambiguity in the grammar where lists of one element are always encoded as the value itself and not as an element of a `list` value. This is an intentional decision to simplify notation. Decoders must take care to accomodate for this.
enum Sisp : Hashable {
	
	/// An integer.
	case integer(Int)
	
	/// A string.
	case string(String)
	
	/// A list of values.
	case list([Sisp])
	
	/// A structure of type `type` containing labelled children `children`.
	case structure(type: String, children: [String : Sisp])
	
	var typeDescription: String {
		switch self {
			case .integer:									return "Integer"
			case .string:									return "String"
			case .list:										return "List"
			case .structure(type: let type, children: _):	return "Structure of type “\(type)”"
		}
	}
	
}
