// Glyco © 2021–2022 Constantino Tsarouhas

extension NT {
	
	/// A program element that, given some arguments, evaluates to a result value.
	public struct Function : Named, SimplyLowerable, Element {
		
		/// Creates a function with given name, parameters, result type, and result.
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
		///
		/// If `resultType` is a nominal type and `result` is of a structural type, it is implicitly casted to `resultType`.
		public var result: Result
		
		// See protocol.
		func lowered(in context: inout LoweringContext) throws -> Lower.Function {
			try .init(name, takes: parameters.lowered(in: &context), returns: resultType.lowered(in: &context), in: result.lowered(in: &context))
		}
		
	}
	
}
