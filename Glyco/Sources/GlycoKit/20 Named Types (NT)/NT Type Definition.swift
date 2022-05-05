// Glyco © 2021–2022 Constantino Tsarouhas

extension NT {
	
	/// A definition of a named type.
	public enum TypeDefinition : Named, Element {
		
		/// A definition of a type that is equivalent to (interchangeable with) its value type.
		case alias(TypeName, ValueType)
		
		/// A definition of a type that is not equivalent to (not interchangeable with) its value type.
		case nominal(TypeName, ValueType)
		
		// See protocol.
		public var name: TypeName {
			switch self {
				case .alias(let name, _),
					.nominal(let name, _):
				return name
			}
		}
		
		/// The value type.
		var valueType: ValueType {
			switch self {
				case .alias(_, let valueType),
					.nominal(_, let valueType):
				return valueType
			}
		}
		
	}
	
}
