// Glyco © 2021–2022 Constantino Tsarouhas

extension CL {
	
	/// A function that creates (or determines) an object's state.
	///
	/// A constructor is run as part of an invocation of the `createObject` method on the object type object and evaluates to a capability to a (usually freshly allocated) record.
	public struct Constructor : SimplyLowerable, Element {
		
		/// Creates a constructor with given parameters and result.
		public init(takes parameters: [Parameter], in result: Value) {
			self.parameters = parameters
			self.result = result
		}
		
		/// The constructor's parameters.
		public var parameters: [Parameter]
		
		/// The constructor's result, which must evaluate to a capability to a (usually freshly allocated) record.
		public var result: Value
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Constructor {
			try .init(takes: parameters.lowered(in: &context), in: result.lowered(in: &context))
		}
		
	}
	
}
