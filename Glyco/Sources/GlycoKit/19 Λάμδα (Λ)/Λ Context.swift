// Glyco © 2021–2022 Constantino Tsarouhas

extension Λ {
	
	/// A value used while lowering.
	struct Context {
		
		/// The anonymous functions discovered while lowering values.
		var anonymousFunctions = [Lower.Function]()
		
		/// A bag of labels.
		var labels = Bag<Lower.Label>()
		
	}
	
}
