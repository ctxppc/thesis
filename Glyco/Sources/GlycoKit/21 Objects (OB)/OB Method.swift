// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A function that can be invoked on an object.
	public struct Method : Codable, Equatable {
		
		/// Creates a method with given name, parameters, result type, and result.
		public init(_ name: Symbol, takes parameters: [Parameter], returns resultType: ValueType, in result: Result) {
			self.name = name
			self.parameters = parameters
			self.resultType = resultType
			self.result = result
		}
		
		/// The method's name.
		public var name: Symbol
		
		/// The method's parameters (excluding the `self` value).
		public var parameters: [Parameter]
		
		/// The method's result type.
		public var resultType: ValueType
		
		/// The method's result, in terms of its `self` value and parameters.
		public var result: Result
		
		/// The symbol referring to the `self` value in a method.
		static let selfName: Symbol = "ob.self"	// shadowing provided by let-binding
		
	}
	
}
