// Glyco © 2021–2022 Constantino Tsarouhas

extension MM {
	
	/// A value used during lowering.
	struct Context {
		
		/// The configuration.
		let configuration: CompilationConfiguration
		
		/// A bag of labels
		var labels = Bag<Label>()
		
	}
	
}
