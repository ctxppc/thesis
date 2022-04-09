// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A value used while lowering a program, function, or method.
	struct Context {
		
		/// The name of the object type being lowered, or `nil` if no object type is being lowered.
		var objectTypeName: TypeName?
		
		/// The type definitions in the current scope, from oldest to newest.
		var types = [TypeDefinition]()
		
		/// Returns the newest definition of a type with given name.
		func type(named name: TypeName) -> TypeDefinition? {
			types.reversed()[name]
		}
		
		/// The values types associated with symbols.
		var valueTypesBySymbol = [Symbol : [ValueType]]()
		
		/// Declares `symbol` to be a value of given type.
		mutating func declare(_ symbol: Symbol, _ type: ValueType) {
			valueTypesBySymbol[symbol, default: []].append(type)
		}
		
		/// Ends the declaration of `symbol` as a value of given type.
		mutating func undeclare(_ symbol: Symbol, _ type: ValueType) {
			let removed = valueTypesBySymbol[symbol, default: []].removeLast()
			assert(removed == type)
		}
		
		/// Returns the type of the value bound to `symbol`, or `nil` if `symbol` is not declared.
		func valueType(of symbol: Symbol) -> ValueType? {
			valueTypesBySymbol[symbol]?.last
		}
		
	}
	
}
