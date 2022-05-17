// Glyco © 2021–2022 Constantino Tsarouhas

extension CL {
	
	/// A function that creates (or determines) an object's state.
	///
	/// An initialiser is run as part of an invocation of the `createObject` method on the object type object and evaluates to a capability to a (usually freshly allocated) record.
	public struct Initialiser : SimplyLowerable, Element {
		
		/// Creates an initialiser with given parameters and result.
		public init(takes parameters: [Parameter], in result: Value) {
			self.parameters = parameters
			self.result = result
		}
		
		/// The initialiser's parameters.
		public var parameters: [Parameter]
		
		/// The initialiser's result, in terms of the initialiser's parameters, evaluating to a capability to a (usually freshly allocated) record.
		///
		/// The initialiser does not capture any names from the object type definition's scope.
		public var result: Value
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Initialiser {
			try .init(takes: parameters.lowered(in: &context), in: result.lowered(in: &context))
		}
		
	}
	
}
