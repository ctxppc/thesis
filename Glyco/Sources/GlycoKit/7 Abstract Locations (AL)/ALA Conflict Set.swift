// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	//sourcery: hasOpaqueRepresentation
	public struct ConflictSet : Equatable {
		
		/// Creates a set with given conflicts.
		public init(_ conflicts: [Conflict]) {
			for conflict in conflicts {
				insert(conflict)
			}
		}
		
		/// A mapping from locations to locations that conflict with the former.
		///
		/// - Invariant: The mapping is symmetric, i.e., for every location `a` and `b`, if `conflictingLocationsForLocation[a]!.contains(b)` then `conflictingLocationsForLocation[b]!.contains(a)`.
		private var conflictingLocationsForLocation: [Location : Set<Location>] = [:]
		
		/// Inserts given conflict to the set.
		///
		/// This method does nothing if `conflict` is a self-conflict.
		mutating func insert(_ conflict: Conflict) {
			guard conflict.first != conflict.second else { return }
			conflictingLocationsForLocation[conflict.first, default: []].insert(conflict.second)
			conflictingLocationsForLocation[conflict.second, default: []].insert(conflict.first)
		}
		
		/// Returns a Boolean value indicating whether the set contains a conflict between `firstLocation` and any location in `otherLocations`.
		func containsConflict(_ firstLocation: Location, _ otherLocations: Set<Location>) -> Bool {
			guard let conflictingLocations = conflictingLocationsForLocation[firstLocation] else { return false }
			return !conflictingLocations.isDisjoint(with: otherLocations)
		}
		
		/// Adds the conflicting location pairs from `other` to `self`.
		mutating func formUnion(with other: Self) {
			for (firstLocation, otherLocations) in other.conflictingLocationsForLocation {
				self.conflictingLocationsForLocation[firstLocation, default: []].formUnion(otherLocations)
			}
		}
		
		/// Returns a Boolean value indicating whether given locations used in a copy effect can be safely coalesced.
		func safelyCoalescable(_ firstLocation: Location, _ otherLocation: Location) -> Bool {
			
			guard !containsConflict(firstLocation, [otherLocation]) else { return false }
			
			// Apply (conservative) heuristic by Briggs et al. to avoid turning a K-colourable conflict graph into non-K-colourable.
			let conflictingLocationsOfUnion = conflictingLocationsForLocation[firstLocation, default: []]
				.union(conflictingLocationsForLocation[otherLocation, default: []])
				.subtracting([firstLocation, otherLocation])
			return conflictingLocationsOfUnion.count /* new conflict count */ < Lower.Register.assignableRegisters.count /* K */
			
		}
		
		/// Returns the locations, ordered by increasing number of conflicts.
		func locationsOrderedByIncreasingNumberOfConflicts() -> [Location] {
			conflictingLocationsForLocation
				.sorted { ($0.value.count, $0.key) < ($1.value.count, $1.key) }	// also order by location for deterministic ordering
				.map(\.key)
		}
		
	}
	
	public struct Conflict : Equatable, Codable {
		
		/// Creates a conflict between two given locations.
		public init(_ first: ALA.Location, _ second: ALA.Location) {
			self.first = first
			self.second = second
		}
		
		/// The first location in the conflict.
		public let first: Location
		
		/// The second location in the conflict.
		public let second: Location
		
	}
	
}

extension ALA.ConflictSet : Codable {
	
	//sourcery: isInternalForm
	public init(from decoder: Decoder) throws {
		try self.init(decoder.singleValueContainer().decode([ALA.Conflict].self))
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.unkeyedContainer()
		for (first, others) in conflictingLocationsForLocation {
			for other in others {
				try container.encode(ALA.Conflict(first, other))
			}
		}
	}
	
}
