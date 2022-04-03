// Glyco © 2021–2022 Constantino Tsarouhas

extension LS {
	
	/// A named value.
	public struct Definition : Codable, Equatable, SimplyLowerable {
		
		/// Creates a definition with given name and value.
		public init(_ name: Symbol, _ value: Value) {
			self.name = name
			self.value = value
		}
		
		/// The definition's name.
		public var name: Symbol
		
		/// The definition's value.
		public var value: Value
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Definition {
			try .init(name.lowered(in: &context), value.lowered(in: &context))
		}
		
	}
	
}
