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
				let location = Lower.Location(rawValue: "\(symbol.rawValue)_\(locationsBySymbol.count)")
				locationsBySymbol[symbol] = location
				return location
			}
		}
		
	}
	
}