// Glyco © 2021–2022 Constantino Tsarouhas

extension LS {
	
	/// A value used while lowering a function.
	struct Context {
		
		/// A mapping from symbols to locations.
		private var locationsBySymbol = [Symbol : Lower.Location]()
		
		/// Returns the location associated for given symbol.
		mutating func location(for symbol: Symbol) -> Lower.Location {
			if let location = locationsBySymbol[symbol] {
				return location
			} else {
				let location = bag.uniqueName(from: symbol.rawValue)
				locationsBySymbol[symbol] = location
				return location
			}
		}
		
		/// The location bag.
		private var bag = Bag<Lower.Location>()
		
	}
	
}