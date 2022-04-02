// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A function that is invoked on an uninitialised object as part of its creation.
	///
	/// An initialiser evaluates to the number 0 if successful and to a nonzero number if not.
	public struct Initialiser : Codable, Equatable {
		
		/// Creates an initialiser with given parameters and result.
		public init(takes parameters: [Parameter], in result: Result) {
			self.parameters = parameters
			self.result = result
		}
		
		/// The initialiser's parameters (excluding the `self` value).
		public var parameters: [Parameter]
		
		/// The function's result, in terms of its `self` value and parameters.
		///
		/// The result evaluates to signed word 0 if initialisation succeeds and to a nonzero signed word if initialisation fails.
		public var result: Result
		
		/// Returns a representation of `self` in the lower language.
		func lowered(in context: inout Context) throws -> Lower.Function {
			
			let previousSelfName = context.selfName
			context.selfName = context.symbols.uniqueName(from: "self")
			defer { context.selfName = previousSelfName }
			
			return .init(
				.init(rawValue: "ob.\(context.objectTypeName ?? "")_init"),
				takes:		parameters,
				returns:	.s32,
				in:			try result.lowered(in: &context)
			)
			
		}
		
	}
	
}
