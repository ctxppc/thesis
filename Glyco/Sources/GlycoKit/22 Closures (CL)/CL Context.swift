// Glyco © 2021–2022 Constantino Tsarouhas

extension CL {
	
	/// A value used while lowering a program.
	struct Context {
		
		/// The name of the object type being lowered, or `nil` if no method is being lowered.
		var objectTypeName: TypeName?
		
		/// The type definitions in the current scope, from oldest to newest.
		var types = [TypeDefinition]()
		
		/// Returns the newest definition of a type with given name.
		func type(named name: TypeName) -> TypeDefinition? {
			types.reversed()[name]
		}
		
		/// A bag of type names.
		var typeNames = Bag<TypeName>()
		
		/// Declares `symbol` to be a value of given type.
		mutating func declare(_ symbol: Symbol, _ type: ValueType) {
			valueTypesBySymbol[symbol, default: []].append(type)
			numberOfDefinitionsByLocalSymbol[symbol, default: 0] += 1
		}
		
		/// Ends the declaration of `symbol` as a value of given type.
		mutating func undeclare(_ symbol: Symbol) {
			valueTypesBySymbol[symbol, default: []].removeLast()
			numberOfDefinitionsByLocalSymbol[symbol, default: 0] -= 1
		}
		
		/// Returns the type of the value bound to `symbol`, or `nil` if `symbol` is not declared.
		func valueType(of symbol: Symbol) -> ValueType? {
			valueTypesBySymbol[symbol]?.last
		}
		
		/// The values types associated with symbols defined in the current or an outer scope.
		private var valueTypesBySymbol = [Symbol : [ValueType]]()
		
		/// Marks `symbol` as being used and returns its value type.
		@discardableResult
		mutating func use(_ symbol: Symbol) throws -> ValueType {
			guard let type = valueType(of: symbol) else { throw TypingError.undefinedSymbol(symbol) }
			if numberOfDefinitionsByLocalSymbol[symbol, default: 0] == 0 {
				capturedSymbols.insert(symbol)
			}
			return type
		}
		
		/// Executes `closure` within a new closure scope and returns a pair consisting of the result of `closure` and a list of captured symbols and their value type.
		mutating func withClosure<V>(parameters: [Parameter], closure: (inout Self) throws -> V) throws -> (V, [(Symbol, ValueType)]) {
			
			// Prepare inner context.
			let (outerLocals, outerCaptures) = (numberOfDefinitionsByLocalSymbol, capturedSymbols)
			(numberOfDefinitionsByLocalSymbol, capturedSymbols) = ([:], [])
			for parameter in parameters {
				declare(parameter.name, parameter.type)
			}
			
			// Perform closure within inner context.
			let result = try closure(&self)
			let innerCaptures = capturedSymbols
			
			// Restore outer context.
			(numberOfDefinitionsByLocalSymbol, capturedSymbols) = (outerLocals, outerCaptures)
			
			// Finish.
			return (result, try innerCaptures.sorted().map { ($0, try use($0)) })	// sort for deterministic ordering
			
		}
		
		/// A mapping from symbols to number of (overriding) definitions of that symbol in the current lambda scope, or program scope if currently not in a lambda scope.
		private var numberOfDefinitionsByLocalSymbol = [Symbol : Int]()
		
		/// The symbols captured by the closure.
		private var capturedSymbols = Set<Symbol>()
		
	}
	
}
