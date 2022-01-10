// Glyco © 2021–2022 Constantino Tsarouhas

extension LS {
	
	/// An identifier for a named value.
	public struct Symbol : RawCodable, Hashable, SimplyLowerable {
		
		// See protocol.
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		
		// See protocol.
		public var rawValue: String
		
		// See protocol.
		func lowered(in context: inout Context) -> Lower.Location {
			context.location(for: self)
		}
		
	}
	
}
