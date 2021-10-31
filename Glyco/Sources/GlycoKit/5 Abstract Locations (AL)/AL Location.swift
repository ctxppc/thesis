// Glyco © 2021 Constantino Tsarouhas

import DepthKit

extension AL {
	
	/// An abstract storage location on an AL machine.
	public struct Location : Hashable {
		
		/// Allocates a new location, different from every other previously allocated location.
		public static func allocate(in context: inout Context) -> Self {
			defer { context.numberOfAllocatedLocations += 1 }
			return Self(sequenceNumber: context.numberOfAllocatedLocations)
		}
		
		/// A number uniquely identifying the storage.
		public let sequenceNumber: Int
		
		/// Returns a representation of `self` in a lower language.
		///
		/// - Parameter homes: A dictionary mapping abstract locations to physical locations.
		///
		/// - Returns: A representation of `self` in a lower language.
		public func lowered(homes: [Location : Lower.Location]) -> Lower.Location {
			homes[self] !! "Expected a home for \(self)"
		}
		
	}
	
}

extension AL.Location : CustomStringConvertible {
	public var description: String {
		"\(sequenceNumber)"
	}
}

extension AL.Location : Codable {
	
	public init(from decoder: Decoder) throws {
		sequenceNumber = try decoder.singleValueContainer().decode(Int.self)
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(sequenceNumber)
	}
	
}
