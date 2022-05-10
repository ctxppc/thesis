// Glyco © 2021–2022 Constantino Tsarouhas

extension CL {
	
	/// A value used while lowering a program.
	struct Context {
		
		/// Symbols defined within the program or lambda body.
		var definedNames = Set<Symbol>()
		
		/// Symbols captured by the closure body.
		var capturedNames = Set<Symbol>()
		
		/// A bag of type names.
		var typeNames = Bag<TypeName>()
		
	}
	
}
