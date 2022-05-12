// Glyco © 2021–2022 Constantino Tsarouhas

extension CL {
	
	/// A function that can be invoked on an object.
	public struct Method : Named, SimplyLowerable, Element {
		
		/// Creates a method with given name, parameters, result type, and result.
		public init(_ name: Symbol, takes parameters: [Parameter], returns resultType: ValueType, in result: Result) {
			self.name = name
			self.parameters = parameters
			self.resultType = resultType
			self.result = result
		}
		
		// See protocol.
		public var name: Symbol
		
		/// The method's parameters (excluding the `self` value).
		public var parameters: [Parameter]
		
		/// The method's result type.
		public var resultType: ValueType
		
		/// The method's result, in terms of its `self` value and parameters.
		public var result: Result
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Method {
			try .init(name, takes: parameters.lowered(in: &context), returns: resultType.lowered(in: &context), in: result.lowered(in: &context))
		}
		
	}
	
}
