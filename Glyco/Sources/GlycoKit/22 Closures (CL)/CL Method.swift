// Glyco © 2021–2022 Constantino Tsarouhas

extension CL {
	
	/// A function that can be invoked on an object.
	public struct Method : Named, SimplyLowerable, Element {
		
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
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Method {
			.init(name, takes: parameters, returns: resultType, in: try result.lowered(in: &context))
		}
		
	}
	
}
