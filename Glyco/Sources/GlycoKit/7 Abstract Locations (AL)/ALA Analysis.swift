// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// A value describing the liveness set and conflict graph at exit of the effect or predicate it's attached to.
	public struct Analysis : Equatable, Codable {
		
		/// Constructs an analysis value.
		public init(conflictingLocationsForLocation: [Location : Set<Location>] = [:], possiblyLiveLocations: Set<Location> = []) {
			self.conflictingLocationsForLocation = conflictingLocationsForLocation
			self.possiblyLiveLocations = possiblyLiveLocations
			// TODO: Enforce `conflictingLocationsForLocation` invariant by inserting symmetric edges
		}
		
		/// A mapping from locations to locations that conflict with the former.
		///
		/// - Invariant: The mapping is symmetric, i.e., for every location `a` and `b`, if `conflictingLocationsForLocation[a]!.contains(b)` then `conflictingLocationsForLocation[b]!.contains(a)`.
		public private(set) var conflictingLocationsForLocation: [Location : Set<Location>]
		
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
		
		/// Adds conflicts between `firstLocation` and `otherLocations`.
		///
		/// This method does not add a conflict between a location and itself.
		private mutating func insertConflict(_ firstLocation: Location, _ otherLocations: Set<Location>) {
			for otherLocation in otherLocations.subtracting([firstLocation]) {
				guard conflictingLocationsForLocation[firstLocation, default: []].insert(otherLocation).inserted else { continue }	// optimisation
				conflictingLocationsForLocation[otherLocation, default: []].insert(firstLocation)
			}
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
			for (firstLocation, otherLocations) in other.conflictingLocationsForLocation {
				self.conflictingLocationsForLocation[firstLocation, default: []].formUnion(otherLocations)
			}
			self.possiblyLiveLocations.formUnion(other.possiblyLiveLocations)
		}
		
		/// Returns a Boolean value indicating whether the analysis' conflict graph contains a conflict between `firstLocation` and any location in `otherLocations`.
		func containsConflict(_ firstLocation: Location, _ otherLocations: Set<Location>) -> Bool {
			guard let conflictingLocations = conflictingLocationsForLocation[firstLocation] else { return false }
			return !conflictingLocations.isDisjoint(with: otherLocations)
		}
		
		/// Returns the locations, ordered by increasing number of conflicts.
		func locationsOrderedByIncreasingNumberOfConflicts() -> [Location] {
			conflictingLocationsForLocation
				.sorted { ($0.value.count, $0.key) < ($1.value.count, $1.key) }	// also order by location for deterministic ordering
				.map(\.key)
		}
		
	}
	
}
