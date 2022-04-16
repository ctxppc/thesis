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
		
		/// Marks given locations as being defined by the effect.
		///
		/// - Parameter definedLocations: The locations that are defined by the effect.
		mutating func markAsDefined<L : Sequence>(_ locations: L) throws where L.Element == Location {
			possiblyLiveLocations.subtract(locations)
			for definedLocation in locations {
				conflicts.insert(between: definedLocation, and: possiblyLiveLocations)
			}
		}
		
		/// Marks given locations as being used by the effect or predicate.
		///
		/// - Parameter possiblyUsedLocations: The locations that are (possibly) used by the effect or predicate.
		mutating func markAsPossiblyUsed<L : Sequence>(_ locations: L) throws where L.Element == Location {
			possiblyLiveLocations.formUnion(locations)
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
