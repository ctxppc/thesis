// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A definition of a named type.
	public enum TypeDefinition : Named, Codable, Equatable, SimplyLowerable {
		
		/// A definition of a type that is equivalent to (interchangeable with) its value type.
		case structural(TypeName, ValueType)
		
		/// A definition of a type that is not equivalent to (not interchangeable with) its value type.
		case nominal(TypeName, ValueType)
		
		/// A definition of a (nominal) object type.
		case object(TypeName, ObjectType)
		
		// See protocol.
		var name: TypeName {
			switch self {
				case .structural(let name, _),
					.nominal(let name, _),
					.object(let name, _):
				return name
			}
		}
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.TypeDefinition {
			switch self {
				
				case .structural(let typeName, let valueType):
				return .structural(typeName, try valueType.lowered(in: &context))
				
				case .nominal(let typeName, let valueType):
				return .nominal(typeName, try valueType.lowered(in: &context))
				
				case .object(let typeName, let objectType):
				return .nominal(typeName, .cap(.record(try objectType.stateRecordType.lowered(in: &context), sealed: true)))
				
			}
		}
		
	}
	
}
