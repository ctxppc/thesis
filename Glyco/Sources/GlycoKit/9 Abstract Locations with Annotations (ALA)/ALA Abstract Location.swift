// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// An abstract storage location on an AL machine.
	public struct AbstractLocation : Name, RawCodable, SimplyLowerable {
		
		// See protocol.
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		
		/// The identifier.
		public var rawValue: String
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Location {
			try context.assignments[self]
		}
		
	}
	
}

extension ALA.AbstractLocation : Comparable {
	public static func <(earlier: Self, later: Self) -> Bool {
		earlier.rawValue < later.rawValue
	}
}
