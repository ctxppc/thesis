// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A definition of a named type.
	public enum TypeDefinition : Named, Codable, Equatable, SimplyLowerable {
		
		/// A name bound to a structural value type.
		case alias(TypeName, ValueType)
		
		/// A name bound to an object type with given initialiser, methods, and state value type.
		case object(TypeName, ObjectType)
		
		// See protocol.
		var name: TypeName {
			switch self {
				case .alias(let name, _),
					.object(let name, _):
				return name
			}
		}
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.TypeDefinition {
			switch self {
				
				case .alias(let typeName, let valueType):
				return .init(typeName, try valueType.lowered(in: &context))
				
				case .object(let typeName, let objectType):
				return .init(typeName, .cap(.record(try objectType.stateRecordType.lowered(in: &context), sealed: true)))
				
			}
		}
		
	}
	
}
