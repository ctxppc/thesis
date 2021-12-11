// Glyco © 2021 Constantino Tsarouhas

extension AL {
	
	/// An undirected graph of locations, with each pair of locations connected when they're (possibly) in conflict, i.e., may simultaneously hold a value that is needed later.
	struct ConflictGraph : Codable {
		
		/// A graph where no location conflicts with another location.
		static let conflictFree = Self()
		
		/// A mapping from locations to locations that conflict with the former.
		private var conflictingLocationsForLocation = [Location : Set<Location>]()
		
		/// A conflict.
		typealias Conflict = (Location, Location)
		
		/// Returns a Boolean value indicating whether the graph contains a conflict between `firstLocation` and any location in `otherLocations`.
		func containsConflict(_ firstLocation: Location, _ otherLocations: Set<Location>) -> Bool {
			guard let conflictingLocations = conflictingLocationsForLocation[firstLocation] else { return false }
			return !conflictingLocations.isDisjoint(with: otherLocations)
		}
		
		/// Adds conflicts between `firstLocation` and `otherLocations`.
		///
		/// This method does not add a conflict between a location and itself.
		mutating func insertConflict(_ firstLocation: Location, _ otherLocations: Set<Location>) {
			for otherLocation in otherLocations.subtracting([firstLocation]) {
				guard conflictingLocationsForLocation[firstLocation, default: []].insert(otherLocation).inserted else { continue }	// optimisation
				conflictingLocationsForLocation[otherLocation, default: []].insert(firstLocation)
			}
		}
		
		/// Adds the conflicting location pairs from `otherGraph` to `self`.
		mutating func formUnion(with otherGraph: Self) {
			for (firstLocation, otherLocations) in otherGraph.conflictingLocationsForLocation {
				self.conflictingLocationsForLocation[firstLocation, default: []].formUnion(otherLocations)
			}
		}
		
		/// Returns the locations in the graph, ordered by increasing number of conflicts.
		func locationsOrderedByIncreasingNumberOfConflicts() -> [Location] {
			conflictingLocationsForLocation
				.sorted { ($0.value.count, $0.key) < ($1.value.count, $1.key) }	// also order by location for deterministic ordering
				.map(\.key)
		}
		
	}
	
}
