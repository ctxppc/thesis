// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A value used while lowering.
	struct Context {
		
		/// Creates a contextual value.
		///
		/// - Parameter inMethod: `true` if lowering a method; otherwise, `false`.
		init(inMethod: Bool) {
			selfName = inMethod ? symbols.uniqueName(from: "self") : nil
		}
		
		/// The name of the current object, or `nil` if the current context isn't a method.
		let selfName: Symbol?
		
		/// A bag of symbols.
		var symbols = Bag<Symbol>()
		
	}
	
}
