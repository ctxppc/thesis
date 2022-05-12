// Glyco © 2021–2022 Constantino Tsarouhas

extension CL {
	
	/// A function that initialises an object's state.
	public struct Initialiser : SimplyLowerable, Element {
		
		/// Creates a constructor with given parameters and effect.
		public init(takes parameters: [Parameter], in effect: Effect) {
			self.parameters = parameters
			self.effect = effect
		}
		
		/// The constructor's parameters.
		public var parameters: [Parameter]
		
		/// The initialiser's effect, in terms of `self` and its parameters.
		public var effect: Effect
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Initialiser {
			try .init(takes: parameters.lowered(in: &context), in: effect.lowered(in: &context))
		}
		
	}
	
}
