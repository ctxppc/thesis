// Glyco © 2021–2022 Constantino Tsarouhas

extension NT {
	
	/// A value used while lowering.
	struct Context {
		
		/// The stacks of value types by name.
		var valueTypesByName = [TypeName : [ValueType]]()
		
	}
	
}
