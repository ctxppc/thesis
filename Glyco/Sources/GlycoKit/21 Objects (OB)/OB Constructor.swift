// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A function that allocates and initialises an object's state.
	public struct Constructor : Codable, Equatable {
		
		/// Creates a constructor with given parameters and result.
		public init(takes parameters: [Parameter], in result: Value) {
			self.parameters = parameters
			self.result = result
		}
		
		/// The constructor's parameters.
		public var parameters: [Parameter]
		
		/// The constructor's result, in terms of its parameters.
		///
		/// The result evaluates to an unsealed capability to the created object's state.
		public var result: Value
		
	}
	
}
