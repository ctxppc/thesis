// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A function that creates (or determines) an object's state.
	///
	/// A constructor is run as part of an invocation of the `createObject` method on the object type object and evaluates to a capability to a (usually freshly allocated) record.
	public struct Constructor : Element {
		
		/// Creates a constructor with given parameters and result.
		public init(takes parameters: [Parameter], in result: Value) {
			self.parameters = parameters
			self.result = result
		}
		
		/// The constructor's parameters.
		public var parameters: [Parameter]
		
		/// The constructor's result, in terms of the constructor's parameters, evaluating to a capability to a (usually freshly allocated) record.
		public var result: Value
		
		/// Returns the type of `result`.
		func resultType(in context: Context) throws -> ValueType {
			try result.type(in: .init(
				types:				context.types,
				valueTypesBySymbol:	.init(uniqueKeysWithValues: parameters.lazy.map { ($0.name, [$0.type]) })
			))
		}
		
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
				returns:	.cap(.record(type.stateRecordType(in: context).lowered(in: &context), sealed: true)),
				in:			.let(
					[sealName ~ .field(ObjectType.typeObjectSealFieldName, of: .named(Method.selfName))],
					in: .value(.sealed(result.lowered(in: &context), with: .named(sealName)))
				)
			)
		}
		
	}
	
}
