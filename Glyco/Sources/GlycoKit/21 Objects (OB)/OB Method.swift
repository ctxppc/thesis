// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A function that can be invoked on an object.
	public struct Method : Named, Element {
		
		/// Creates a method with given name, parameters, result type, and result.
		public init(_ name: Symbol, takes parameters: [Parameter], returns resultType: ValueType, in result: Result) {
			self.name = name
			self.parameters = parameters
			self.resultType = resultType
			self.result = result
		}
		
		// See protocol.
		public var name: Symbol
		
		/// The method's parameters (excluding the `self` value).
		public var parameters: [Parameter]
		
		/// The method's result type.
		public var resultType: ValueType
		
		/// The method's result, in terms of its `self` value and parameters.
		public var result: Result
		
		/// The symbol referring to the `self` value in a method.
		static let selfName: Lower.Symbol = "ob.self"	// shadowing provided by let-binding
		
		/// The symbol of the function for `self`, as defined by in a `letType` value.
		func symbol(typeName: TypeName) -> Lower.Symbol {
			Self.symbol(typeName: typeName, methodName: self.name)
		}
		
		/// The symbol of the function for a method named `methodName` in a object type named `typeName`, as defined by in a `letType` value.
		static func symbol(typeName: TypeName, methodName: Self.Name) -> Lower.Symbol {
			"ob.\(typeName).\(methodName).m"
		}
		
		/// Returns an *unsealed* lambda representing `self`.
		///
		/// The lambda's parameters consists of one sealed parameter for the method's receiver followed by `parameters`. The lambda's result type and result are `resultType` and `result` respectively.
		///
		/// - Parameter type: The object type defining `self`.
		/// - Parameter context: The lowering context.
		func lowered(in context: inout Context, type: ObjectType) throws -> Lower.Value {
			let receiverType = Lower.ValueType.cap(.record(try type.state.lowered(in: &context), sealed: true))
			return try .λ(
				takes:		[.init(Self.selfName, receiverType, sealed: true)] + parameters.lowered(in: &context),
				returns:	resultType.lowered(in: &context),
				in:			result.lowered(in: &context)
			)
		}
		
	}
	
}
