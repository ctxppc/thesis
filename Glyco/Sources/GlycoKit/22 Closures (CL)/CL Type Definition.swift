// Glyco © 2021–2022 Constantino Tsarouhas

extension CL {
	
	/// A definition of a named type.
	public enum TypeDefinition : Named, SimplyLowerable, Element {
		
		/// A definition of a type that is equivalent to (interchangeable with) its value type.
		case alias(TypeName, ValueType)
		
		/// A definition of a type that is not equivalent to (not interchangeable with) its value type.
		case nominal(TypeName, ValueType)
		
		/// A definition of a (nominal) object type.
		case object(ObjectType)
		
		// See protocol.
		public var name: TypeName {
			switch self {
				
				case .alias(let name, _),
					.nominal(let name, _):
				return name
				
				case .object(let type):
				return type.name
				
			}
		}
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.TypeDefinition {
			switch self {
				case .alias(let name, let type):	return .alias(name, type)
				case .nominal(let name, let type):	return .nominal(name, type)
				case .object(let type):				return .object(try type.lowered(in: &context))
			}
		}
		
	}
	
}
