// Glyco © 2021 Constantino Tsarouhas

import DepthKit

extension AL {
	
	/// An abstract storage location on an AL machine.
	public struct Location : Codable, Hashable {
		
		/// Allocates a new location, different from every other previously allocated location.
		public static func allocate(scopeIdentifier: String = "tmp", context: inout Context) -> Self {
			defer { context.numberOfAllocatedLocations += 1 }
			return Self(scopeIdentifier: scopeIdentifier, sequenceNumber: context.numberOfAllocatedLocations)
		}
		
		/// A value identifying the score of the storage.
		public let scopeIdentifier: String
		
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
		"\(scopeIdentifier).\(sequenceNumber)"
	}
}
