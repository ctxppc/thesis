// Glyco © 2021–2022 Constantino Tsarouhas

extension EX {
	
	/// A value used while lowering a program or function.
	struct Context {
		
		/// The program's functions.
		let functions: [Function]
		
		/// The symbol bag.
		var symbols = Bag<Lower.Symbol>()
		
		/// A mapping from symbols to value types.
		var valueTypesBySymbol = [Symbol : ValueType]()
		
	}
	
}
