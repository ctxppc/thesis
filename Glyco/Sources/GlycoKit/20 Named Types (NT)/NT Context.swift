// Glyco © 2021–2022 Constantino Tsarouhas

extension NT {
	
	/// A value used while lowering.
	struct Context {
		
		/// The type definitions in the current scope, from oldest to newest.
		var types = [TypeDefinition]()
		
		/// Returns the newest definition of a type with given name.
		func type(named name: TypeName) -> TypeDefinition? {
			types.reversed()[name]
		}
		
	}
	
}
