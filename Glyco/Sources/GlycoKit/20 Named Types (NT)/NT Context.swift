// Glyco © 2021–2022 Constantino Tsarouhas

extension NT {
	
	/// A value used while lowering.
	struct LoweringContext : NTTypeContext {
		
		// See protocol.
		func type(named name: TypeName) -> TypeDefinition? {
			types.reversed()[name]
		}
		
		/// The type definitions in the current scope, from oldest to newest.
		var types = [TypeDefinition]()
		
	}
	
	/// A value used while typing.
	struct TypingContext : NTTypeContext {
		
		/// The program's global functions.
		let functions: [Function]
		
		/// The type definitions in the current scope, from oldest to newest.
		var types = [TypeDefinition]()
		
		// See protocol.
		func type(named name: TypeName) -> TypeDefinition? {
			types.reversed()[name]
		}
		
		/// A mapping from symbols to assigned types.
		var assignedTypesBySymbol = [Symbol : AssignedValueType]()
		
	}
	
	/// A type assigned to a value.
	struct AssignedValueType {
		
		/// Determines the value type assigned to a value in some context.
		init(from actual: ValueType, in context: TypingContext) throws {
			self.actual = actual
			self.normalised = try actual.normalised(in: context)
			self.structural = try actual.structural(in: context)
		}
		
		/// The value's actual type, without any type name resolution.
		let actual: ValueType
		
		/// The value's normalised type.
		let normalised: ValueType
		
		/// The value's structural type.
		let structural: ValueType
		
	}
	
}

protocol NTTypeContext {
	
	/// Returns the newest definition of a type with given name.
	func type(named name: NT.TypeName) -> NT.TypeDefinition?
	
}
