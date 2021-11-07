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
		
		/// Returns a Boolean value indicating whether the graph contains `conflict`.
		func containsConflict(_ firstLocation: Location, _ otherLocations: Set<Location>) -> Bool {
			guard let conflictingLocations = conflictingLocationsForLocation[firstLocation] else { return false }
			return !conflictingLocations.isDisjoint(with: otherLocations)
		}
		
		/// Adds given conflict to the graph.
		///
		/// This method does nothing if the conflict names the same location twice.
		mutating func insert(_ conflict: Conflict) {
			guard conflict.0 != conflict.1 else { return }
			guard conflictingLocationsForLocation[conflict.0, default: []].insert(conflict.1).inserted else { return }	// optimisation
			conflictingLocationsForLocation[conflict.1, default: []].insert(conflict.0)
		}
		
		/// Adds conflicts between `firstLocation` and `otherLocations`.
		mutating func insertConflict(_ firstLocation: Location, _ otherLocations: Set<Location>) {
			for otherLocation in otherLocations {
				insert((firstLocation, otherLocation))
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
				.sorted { $0.value.count < $1.value.count }
				.map(\.key)
		}
		
	}
	
}
