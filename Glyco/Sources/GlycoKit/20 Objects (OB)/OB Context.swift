// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A value used while lowering.
	struct Context {
		
		/// The name of the current object, or `nil` if the current context isn't a method.
		var selfName: Symbol?
		
	}
	
}
