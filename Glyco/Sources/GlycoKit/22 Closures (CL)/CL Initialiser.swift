// Glyco © 2021–2022 Constantino Tsarouhas

extension CL {
	
	/// A function that initialises an object's state.
	public struct Initialiser : Element {
		
		/// Creates a constructor with given parameters and effect.
		public init(takes parameters: [Parameter], in effect: Effect) {
			self.parameters = parameters
			self.effect = effect
		}
		
		/// The constructor's parameters.
		public var parameters: [Parameter]
		
		/// The initialiser's effect, in terms of `self` and its parameters.
		public var effect: Effect
		
		/// Returns an *unsealed* lambda representing the `createObject` method on the type object representing `type`.
		///
		/// The lambda's parameters consists of one sealed parameter for the method's receiver, i.e. the type object, followed by `parameters`, and returns a sealed capability to the created object.
		///
		/// - Parameter type: The object type defining `self`.
		/// - Parameter context: The lowering context.
		func lowered(in context: inout Context, type: ObjectType) throws -> Lower.Initialiser {
			.init(takes: parameters, in: try effect.lowered(in: &context))
		}
		
	}
	
}
