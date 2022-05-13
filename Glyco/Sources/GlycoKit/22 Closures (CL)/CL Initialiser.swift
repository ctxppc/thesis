// Glyco © 2021–2022 Constantino Tsarouhas

extension CL {
	
	/// A function that initialises an object's state.
	public struct Initialiser : SimplyLowerable, Element {
		
		/// Creates a constructor with given parameters and result.
		public init(takes parameters: [Parameter], in result: Value) {
			self.parameters = parameters
			self.result = result
		}
		
		/// The constructor's parameters.
		public var parameters: [Parameter]
		
		/// The initialiser's result, which must evaluate to a (usually freshly allocated) record capability.
		public var result: Value
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Initialiser {
			try .init(takes: parameters.lowered(in: &context), in: result.lowered(in: &context))
		}
		
	}
	
}
