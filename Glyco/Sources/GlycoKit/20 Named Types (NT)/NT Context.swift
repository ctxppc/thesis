// Glyco © 2021–2022 Constantino Tsarouhas

extension NT {
	
	/// A value used while lowering.
	struct Context {
		
		/// The stacks of value types by name.
		var valueTypesByName = [TypeName : [ValueType]]()
		
		mutating func push(_ definitions: [TypeDefinition]) {
			for definition in definitions {
				valueTypesByName[definition.name, default: []].append(definition.type)
			}
		}
		
		mutating func pop(_ definitions: [TypeDefinition]) {
			for definition in definitions.reversed() {
				let removed = valueTypesByName[definition.name, default: []].removeLast()
				assert(removed == definition.type)
			}
		}
		
	}
	
}
