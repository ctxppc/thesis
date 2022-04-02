// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A function that can be invoked on an object.
	public struct Method : Codable, Equatable, SimplyLowerable {
		
		/// Creates a method with given name, parameters, result type, and result.
		public init(_ name: Name, takes parameters: [Parameter], returns resultType: ValueType, in result: Result) {
			self.name = name
			self.parameters = parameters
			self.resultType = resultType
			self.result = result
		}
		
		/// The method's name.
		public var name: Name
		public struct Name : GlycoKit.Name, SimplyLowerable {
			
			// See protocol.
			public init(rawValue: String) {
				self.rawValue = rawValue
			}
			
			// See protocol.
			public var rawValue: String
			
			// See protocol.
			func lowered(in context: inout Context) -> Label {
				.init(rawValue: "ob.\(context.objectTypeName ?? "")_\(rawValue)")
			}
			
		}
		
		/// The method's parameters (excluding the `self` value).
		public var parameters: [Parameter]
		
		/// The method's result type.
		public var resultType: ValueType
		
		/// The method's result, in terms of its `self` value and parameters.
		public var result: Result
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Function {
			let previousSelfName = context.selfName
			context.selfName = context.symbols.uniqueName(from: "self")
			defer { context.selfName = previousSelfName }
			return try .init(
				name.lowered(in: &context),
				takes:		parameters,
				returns:	resultType.lowered(in: &context),
				in:			result.lowered(in: &context)
			)
		}
		
	}
	
}
