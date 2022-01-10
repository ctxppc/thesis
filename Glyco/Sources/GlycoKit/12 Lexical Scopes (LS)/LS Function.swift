// Glyco © 2021–2022 Constantino Tsarouhas

extension LS {
	
	/// A program element that, given some arguments, evaluates to a result value.
	public struct Function : Codable, Equatable, SimplyLowerable {
		
		public init(_ name: Label, _ parameters: [Parameter], _ result: Value) {
			self.name = name
			self.parameters = parameters
			self.result = result
		}
		
		/// The function's name.
		public var name: Label
		
		/// The function's parameters.
		public var parameters: [Parameter]
		
		/// The function's result, in terms of its parameters.
		public var result: Value
		
		// See protocol.
		func lowered(in context: inout ()) throws -> Lower.Function {
			var context = LS.Context()
			return try .init(name, parameters.lowered(in: &context), result.lowered(in: &context))
		}
		
	}
	
}
