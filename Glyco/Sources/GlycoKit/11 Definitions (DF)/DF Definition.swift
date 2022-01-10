// Glyco © 2021–2022 Constantino Tsarouhas

extension DF {
	
	/// A named value.
	public struct Definition : Codable, Equatable, SimplyLowerable {
		
		/// Creates a definition with given name and value.
		public init(_ name: Location, _ value: Value) {
			self.name = name
			self.value = value
		}
		
		/// The definition's (function-wide) name.
		public var name: Location
		
		/// The definition's value.
		public var value: Value
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Effect {
			try .set(name, to: value.lowered(in: &context))
		}
		
	}
	
}
