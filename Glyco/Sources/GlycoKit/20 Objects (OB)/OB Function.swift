// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A program element that, given some arguments, evaluates to a result value.
	public struct Function : Codable, Equatable, SimplyLowerable {
		
		/// Creates a function with given name, parameters, result type, and effect.
		public init(_ name: Label, takes parameters: [Parameter], returns resultType: ValueType, in result: Result) {
			self.name = name
			self.parameters = parameters
			self.resultType = resultType
			self.result = result
		}
		
		/// The function's name.
		public var name: Label
		
		/// The function's parameters.
		public var parameters: [Parameter]
		
		/// The function's result type.
		public var resultType: ValueType
		
		/// The function's result, in terms of its parameters.
		public var result: Result
		
		// See protocol.
		func lowered(in context: inout ()) throws -> Lower.Function {
			var context = OB.Context(inMethod: false)
			return try .init(name, takes: parameters, returns: resultType.lowered(), in: result.lowered(in: &context))
		}
		
	}
	
}
