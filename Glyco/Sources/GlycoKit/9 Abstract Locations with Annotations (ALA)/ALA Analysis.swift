// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// A value describing the liveness set and conflict graph at entry of the effect or predicate it's attached to.
	public struct Analysis : Equatable, Codable {
		
		/// Constructs an analysis value.
		public init(conflicts: ConflictGraph = .init([]), possiblyLiveLocations: Set<Location> = []) {
			self.conflicts = conflicts
			self.possiblyLiveLocations = possiblyLiveLocations
		}
		
		/// The conflict set.
		///
		/// The conflict set grows while traversing a program in reverse order. A location that is defined conflicts with all locations (except itself) that are marked as possibly used at the time.
		public private(set) var conflicts: ConflictGraph
		
		/// The locations whose values are possibly used by a successor.
		///
		/// This set grows and shrinks while traversing a program in reverse order. A location that is defined is removed from the set whereas a location that is used is added to the set.
		public private(set) var possiblyLiveLocations: Set<Location>
		
		/// Updates the analysis with information about an effect or predicate.
		///
		/// - Parameters:
		///    - defined: The locations that are defined by the effect.
		///    - possiblyUsed: The locations that are (possibly) used by the effect or predicate.    
		mutating func update<D : Sequence, U : Sequence>(defined: D, possiblyUsed: U) throws where D.Element == Location, U.Element == Location {
			let possiblyLiveLocationsAtExit = possiblyLiveLocations
			markAsDefinitelyDiscarded(defined)
			markAsPossiblyUsedLater(possiblyUsed)	// a self-copy (both "discarded" & "used") is considered possibly used, so add used after discarded
			for definedLocation in defined {
				conflicts.insert(between: definedLocation, and: possiblyLiveLocationsAtExit)
			}
		}
		
		/// Returns a copy of `self` with additional information about an effect or predicate applied to it.
		///
		/// - Parameters:
		///    - defined: The locations that are defined by the effect.
		///    - possiblyUsed: The locations that are (possibly) used by the effect or predicate.
		func updated<D : Sequence, U : Sequence>(defined: D, possiblyUsed: U) throws -> Self where D.Element == Location, U.Element == Location {
			var copy = self
			try copy.update(defined: defined, possiblyUsed: possiblyUsed)
			return copy
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
		
		// See protocol.
		public func encode(to encoder: Encoder) throws {	// behaves like a derived conformance except for sorting to get deterministic ordering
			var container = encoder.container(keyedBy: CodingKeys.self)
			try container.encode(conflicts, forKey: .conflicts)
			try container.encode(possiblyLiveLocations.sorted(), forKey: .possiblyLiveLocations)
		}
		
	}
	
}
