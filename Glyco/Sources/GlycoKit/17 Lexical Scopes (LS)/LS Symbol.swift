// Glyco © 2021–2022 Constantino Tsarouhas

extension LS {
	
	/// An identifier for a named value.
	public struct Symbol : SimplyLowerable, Name {
		
		// See protocol.
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		
		// See protocol.
		public init(stringLiteral: String) {
			self.init(rawValue: stringLiteral)
		}
		
		// See protocol.
		public var rawValue: String
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Location {
			try context.location(for: self)
		}
		
	}
	
}
