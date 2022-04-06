// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A value used while lowering a program, function, or method.
	struct Context {
		
		/// The name of the current object, or `nil` if no method is being lowered.
		var selfName: Symbol?
		
		/// The name of the object type being lowered, or `nil` if no object type is being lowered.
		var objectTypeName: TypeName?
		
		/// The type definitions in the current scope.
		var types = [TypeDefinition]()
		
		/// A bag of symbols.
		var symbols = Bag<Symbol>()
		
		/// A bag of labels.
		var labels = Bag<Label>()
		
	}
	
}
