// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension LS {
	
	/// A value used while lowering a function.
	struct Context {
		
		/// A mapping from symbols to locations.
		private var locationStackBySymbol = [Symbol : [Lower.Location]]()
		
		/// Returns the location associated for given symbol.
		func location(for symbol: Symbol) throws -> Lower.Location {
			guard let location = locationStackBySymbol[symbol]?.last else { throw LoweringError.undefinedSymbol(symbol) }
			return location
		}
		
		/// Pushes a new scope for given symbol.
		mutating func pushScope<S : Sequence>(for symbols: S) where S.Element == Symbol {
			for symbol in symbols {
				locationStackBySymbol[symbol, default: []].append(locations.uniqueName(from: symbol.rawValue))
			}
		}
		
		/// Pops the current scope for given symbol.
		mutating func popScope<S : Sequence>(for symbols: S) where S.Element == Symbol {
			for symbol in symbols {
				locationStackBySymbol[symbol, default: []].removeLast()
			}
		}
		
		/// The location bag.
		var locations = Bag<Lower.Location>()
		
	}
	
	enum LoweringError : LocalizedError {
		
		/// An error indicating that given symbol is not defined.
		case undefinedSymbol(Symbol)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .undefinedSymbol(let symbol):
				return "“\(symbol)” is not defined"
			}
		}
		
	}
	
}
