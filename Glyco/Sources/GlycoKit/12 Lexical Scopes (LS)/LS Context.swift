// Glyco © 2021–2022 Constantino Tsarouhas

extension LS {
	
	/// A value used while lowering a function.
	struct Context {
		
		/// A mapping from symbols to locations.
		private var locationsBySymbol = [Symbol : Lower.Location]()
		
		/// Returns the location associated for given symbol.
		mutating func location(for symbol: Symbol) -> Lower.Location {
			locationsBySymbol[symbol, default: bag.uniqueName(from: symbol.rawValue)]
		}
		
		/// The location bag.
		private var bag = Bag<Lower.Location>()
		
	}
	
}
