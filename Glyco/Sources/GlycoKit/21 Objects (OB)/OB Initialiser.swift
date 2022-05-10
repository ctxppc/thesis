// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
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
		func lowered(in context: inout Context, type: ObjectType) throws -> Lower.Value {
			let receiverType = Lower.ValueType.cap(.record(try ObjectType.typeObjectState.lowered(in: &context), sealed: true))
			let sealName: Lower.Symbol = "ob.seal"
			return try .λ(
				takes:		[.init(Method.selfName, receiverType, sealed: true)] + parameters.lowered(in: &context),
				returns:	.cap(.record(type.stateRecordType(in: context).lowered(in: &context), sealed: false)),
				in:			.let(
					[
						sealName ~ .field(ObjectType.typeObjectSealFieldName, of: .named(Method.selfName)),
						Method.selfName ~ .record(type.initialState.lowered(in: &context)),
					],
					in: .do(
						[effect.lowered(in: &context)],
						then: .value(.sealed(.named(Method.selfName), with: .named(sealName)))
					)
				)
			)
		}
		
	}
	
}
