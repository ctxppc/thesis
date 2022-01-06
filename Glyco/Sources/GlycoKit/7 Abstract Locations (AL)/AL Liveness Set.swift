// Glyco © 2021–2022 Constantino Tsarouhas

extension AL {
	
	/// A partition of abstract locations into either possibly alive or definitely dead between the execution of an effect and its successor.
	struct LivenessSet {
		
		/// A liveness set where every location's value is definitely not used by a successor.
		static let nothingUsed = Self()
		
		/// The locations whose values are possibly used by a successor.
		private(set) var possiblyAliveLocations: Set<Location> = []
		
		/// Marks `locations` as being possibly used by a successor.
		mutating func markAsPossiblyUsedLater<Locations : Sequence>(_ locations: Locations) where Locations.Element == Location {
			possiblyAliveLocations.formUnion(locations)
		}
		
		/// Marks `locations` as being definitely discarded by a successor.
		mutating func markAsDefinitelyDiscarded<Locations : Sequence>(_ locations: Locations) where Locations.Element == Location {
			possiblyAliveLocations.subtract(locations)
		}
		
		/// Marks the possibly alive locations in `other` as possibly alive in `self`.
		mutating func formUnion(with other: Self) {
			self.possiblyAliveLocations.formUnion(other.possiblyAliveLocations)
		}
		
	}
	
}
