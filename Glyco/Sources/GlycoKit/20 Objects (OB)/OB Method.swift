// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A function that can be invoked on an object.
	public struct Method : Codable, Equatable, SimplyLowerable {
		
		/// Creates a method with given name, parameters, result type, and result.
		public init(_ name: Label, takes parameters: [Parameter], returns resultType: ValueType, in result: Result) {
			self.name = name
			self.parameters = parameters
			self.resultType = resultType
			self.result = result
		}
		
		/// The function's name.
		public var name: Label
		
		/// The function's parameters (excluding the `self` value).
		public var parameters: [Parameter]
		
		/// The function's result type.
		public var resultType: ValueType
		
		/// The function's result, in terms of its `self` value and parameters.
		public var result: Result
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Function {
			var context = OB.Context(inMethod: true)
			return try .init(name, takes: parameters, returns: resultType.lowered(), in: result.lowered(in: &context))
		}
		
	}
	
}
