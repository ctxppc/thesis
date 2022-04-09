// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A value used while lowering a program, function, or method.
	struct Context {
		
		/// The name of the object type being lowered, or `nil` if no object type is being lowered.
		var objectTypeName: TypeName?
		
		/// The type definitions in the current scope, from oldest to newest.
		var types = [TypeDefinition]()
		
		/// Returns the newest definition of a type with given name.
		func type(named name: TypeName) -> TypeDefinition? {
			types.reversed()[name]
		}
		
	}
	
}
