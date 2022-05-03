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
		
		/// A mapping from symbols to value types.
		var valueTypesBySymbol = [Symbol : ValueType]()
		
	}
	
}

protocol NTTypeContext {
	
	/// Returns the newest definition of a type with given name.
	func type(named name: NT.TypeName) -> NT.TypeDefinition?
	
}
