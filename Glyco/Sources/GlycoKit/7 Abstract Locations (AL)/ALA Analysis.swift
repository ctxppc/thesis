// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// A value describing the liveness set and conflict graph at entry of the effect or predicate it's attached to.
	public struct Analysis : Equatable, Codable {
		
		/// Constructs an analysis value.
		public init(conflicts: ConflictSet = .init([]), possiblyLiveLocations: Set<Location> = []) {
			self.conflicts = conflicts
			self.possiblyLiveLocations = possiblyLiveLocations
		}
		
		/// The conflict set.
		public private(set) var conflicts: ConflictSet
		
		/// The locations whose values are possibly used by a successor.
		public private(set) var possiblyLiveLocations: Set<Location>
		
		/// Updates the analysis with information about an effect or predicate.
		///
		/// - Parameters:
		///    - defined: The locations that are defined by the effect.
		///    - possiblyUsed: The locations that are (possibly) used by the effect or predicate.
		mutating func update<D : Sequence, U : Sequence>(defined: D, possiblyUsed: U) where D.Element == Location, U.Element == Location {
			let possiblyLiveLocationsAtExit = possiblyLiveLocations
			markAsDefinitelyDiscarded(defined)
			markAsPossiblyUsedLater(possiblyUsed)	// a self-copy (both "discarded" & "used") is considered possibly used, so add poss. used after def. discarded
			for definedLocation in defined {
				insertConflict(definedLocation, possiblyLiveLocationsAtExit)
			}
		}
		
		/// Returns a copy of `self` with additional information about an effect or predicate applied to it.
		///
		/// - Parameters:
		///    - defined: The locations that are defined by the effect.
		///    - possiblyUsed: The locations that are (possibly) used by the effect or predicate.
		func updated<D : Sequence, U : Sequence>(defined: D, possiblyUsed: U) -> Self where D.Element == Location, U.Element == Location {
			var copy = self
			copy.update(defined: defined, possiblyUsed: possiblyUsed)
			return copy
		}
		
		/// Adds conflicts between `firstLocation` and `otherLocations`.
		///
		/// This method does not add a conflict between a location and itself.
		private mutating func insertConflict(_ firstLocation: Location, _ otherLocations: Set<Location>) {
			for otherLocation in otherLocations {
				conflicts.insert(.init(firstLocation, otherLocation))
			}
		}
		
		/// Returns a Boolean value indicating whether the analysis' conflict graph contains a conflict between `firstLocation` and any location in `otherLocations`.
		func containsConflict(_ firstLocation: Location, _ otherLocations: Set<Location>) -> Bool {
			conflicts.containsConflict(firstLocation, otherLocations)
		}
		
		/// Marks `locations` as being possibly used by a successor.
		private mutating func markAsPossiblyUsedLater<Locations : Sequence>(_ locations: Locations) where Locations.Element == Location {
			possiblyLiveLocations.formUnion(locations)
		}
		
		/// Marks `locations` as being definitely discarded by a successor.
		private mutating func markAsDefinitelyDiscarded<Locations : Sequence>(_ locations: Locations) where Locations.Element == Location {
			possiblyLiveLocations.subtract(locations)
		}
		
		/// Adds the conflicting location pairs from `other` to `self` and marks the possibly live locations in `other` as possibly live in `self`.
		mutating func formUnion(with other: Self) {
			self.conflicts.formUnion(with: other.conflicts)
			self.possiblyLiveLocations.formUnion(other.possiblyLiveLocations)
		}
		
		/// Returns a Boolean value indicating whether given locations used in a copy effect can be safely coalesced.
		func safelyCoalescable(_ firstLocation: Location, _ otherLocation: Location) -> Bool {
			conflicts.safelyCoalescable(firstLocation, otherLocation)
		}
		
		/// Returns the locations, ordered by increasing number of conflicts.
		func locationsOrderedByIncreasingNumberOfConflicts() -> [Location] {
			conflicts.locationsOrderedByIncreasingNumberOfConflicts()
		}
		
	}
	
}
