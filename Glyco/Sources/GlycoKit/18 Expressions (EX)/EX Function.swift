// Glyco © 2021–2022 Constantino Tsarouhas

extension EX {
	
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
		public var result: Result
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Function {
			var context = Context(functions: context.functions)
			for parameter in parameters {
				if parameter.sealed {
					guard case .cap(let capType) = parameter.type else { throw TypingError.noncapabilitySealedParameter(parameter) }
					context.declare(parameter.name, .cap(capType.unsealed()))
				} else {
					context.declare(parameter.name, parameter.type)
				}
			}
			return .init(name, takes: parameters, returns: resultType, in: try result.lowered(in: &context))
		}
		
	}
	
}
