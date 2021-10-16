// Glyco © 2021 Constantino Tsarouhas

import DepthKit

extension AL {
	
	/// An abstract storage location on an AL machine.
	public struct Location : Codable, Hashable {
		
		/// Allocates a new location, different from every other previously allocated location.
		public static func allocate(scopeIdentifier: String = "tmp") -> Self {
			defer { allocations += 1 }
			return Self(scopeIdentifier: scopeIdentifier, sequenceNumber: allocations)
		}
		
		/// The number of locations allocated.
		private static var allocations = 0
		
		/// A value identifying the score of the storage.
		public let scopeIdentifier: String
		
		/// A number uniquely identifying the storage.
		public let sequenceNumber: Int
		
	}
	
}

extension AL.Location : CustomStringConvertible {
	public var description: String {
		"\(scopeIdentifier).\(sequenceNumber)"
	}
}

extension AL.Location {
	
	/// Returns an NE representation of `self`.
	///
	/// - Parameter homes: A dictionary mapping abstract locations to physical locations.
	///
	/// - Returns: An NE representation of `self`.
	public func neLocation(homes: [AL.Location : NE.Location]) -> NE.Location {
		homes[self] !! "Expected a home for \(self)"
	}
	
}
