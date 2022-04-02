// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A value used while lowering a program, function, or method.
	struct Context {
		
		/// The name of the current object, or `nil` if the current context isn't a method.
		var selfName: Symbol?
		
		/// The type definitions in the current scope.
		var typeDefinitions: [TypeDefinition]
		
		/// A bag of symbols.
		var symbols = Bag<Symbol>()
		
	}
	
}
