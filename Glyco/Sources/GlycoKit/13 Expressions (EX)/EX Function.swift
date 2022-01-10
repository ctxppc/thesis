// Glyco © 2021–2022 Constantino Tsarouhas

extension EX {
	
	/// A program element that, given some arguments, evaluates to a result value.
	public struct Function : Codable, Equatable, SimplyLowerable {
		
		public init(_ name: Label, _ parameters: [Parameter], _ result: Result) {
			self.name = name
			self.parameters = parameters
			self.result = result
		}
		
		/// The function's name.
		public var name: Label
		
		/// The function's parameters.
		public var parameters: [Parameter]
		
		/// The function's result, in terms of its parameters.
		public var result: Result
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Function {
			.init(name, parameters, try result.lowered(in: &context))
		}
		
	}
	
}
