// Glyco © 2021–2022 Constantino Tsarouhas

extension EX {
	
	/// A value used while lowering a program or function.
	struct Context {
		
		init(functions: [EX.Function]) {
			self.functions = functions
		}
		
		/// The program's functions.
		let functions: [Function]
		
		/// The symbol bag.
		var symbols = Bag<Lower.Symbol>()
		
		/// A mapping from symbols to stacks of value types.
		private var valueTypeStacksBySymbol = [Symbol : [ValueType]]()
		
		/// Returns the type of the value bound to `symbol`, or `nil` if `symbol` isn't declared.
		func type(of symbol: Symbol) -> ValueType? {
			valueTypeStacksBySymbol[symbol]?.last
		}
		
		/// Declares `symbol` to be a value of type `type`.
		mutating func declare(_ symbol: Symbol, _ type: ValueType) {
			valueTypeStacksBySymbol[symbol, default: []].append(type)
		}
		
		/// Ends the declaration of `symbol`.
		mutating func undeclare(_ symbol: Symbol) {
			valueTypeStacksBySymbol[symbol, default: []].removeLast()
		}
		
	}
	
}
