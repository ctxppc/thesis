// Glyco © 2021 Constantino Tsarouhas

import DepthKit

/// An abstract storage location on an AL machine.
struct ALLocation : Codable, Hashable {
	
	/// Allocates a new location, different from every other previously allocated location.
	static func allocate(scopeIdentifier: String = "tmp") -> Self {
		defer { allocations += 1 }
		return Self(scopeIdentifier: scopeIdentifier, sequenceNumber: allocations)
	}
	
	/// The number of locations allocated.
	private static var allocations = 0
	
	/// A value identifying the score of the storage.
	let scopeIdentifier: String
	
	/// A number uniquely identifying the storage.
	let sequenceNumber: Int
	
}

extension ALLocation : CustomStringConvertible {
	var description: String {
		"\(scopeIdentifier).\(sequenceNumber)"
	}
}

extension ALLocation {
	
	/// Returns an NE representation of `self`.
	///
	/// - Parameter homes: A dictionary mapping abstract locations to physical locations.
	///
	/// - Returns: An NE representation of `self`.
	func neLocation(homes: [ALLocation : NELocation]) -> NELocation {
		homes[self] !! "Expected a home for \(self)"
	}
	
}
