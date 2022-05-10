// Glyco © 2021–2022 Constantino Tsarouhas

extension Λ {
	
	/// A value used while lowering a program.
	struct Context {
		
		/// The functions discovered while lowering lambda values.
		var lambdaFunctions = [Lower.Function]()
		
		/// A bag of labels.
		var labels = Bag<Lower.Label>()
		
	}
	
}
