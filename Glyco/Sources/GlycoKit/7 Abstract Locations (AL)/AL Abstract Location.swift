// Glyco © 2021–2022 Constantino Tsarouhas

import Algorithms
import DepthKit

extension AL {
	
	/// An abstract storage location on an AL machine.
	public struct AbstractLocation : RawCodable, Hashable, SimplyLowerable {
		
		// See protocol.
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		
		/// The identifier.
		public var rawValue: String
		
		// See protocol.
		func lowered(in context: inout LocalContext) -> Lower.Location {
			context.assignments[self]
		}
		
	}
	
}

extension AL.AbstractLocation : Comparable {
	public static func <(earlier: Self, later: Self) -> Bool {
		earlier.rawValue < later.rawValue
	}
}
