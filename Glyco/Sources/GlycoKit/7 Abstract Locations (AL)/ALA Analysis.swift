// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// A value describing the liveness set and conflict graph at entry of the effect or predicate it's attached to.
	public struct Analysis : Equatable, Codable {
		
		/// Constructs an analysis value.
		public init(
			conflicts:						ConflictSet = .init([]),
			possiblyLiveLocations:			Set<Location> = [],
			definedLocations:				Set<Location> = [],
			possiblyUsedUndefinedLocations:	Set<Location> = [],
			declarations:					Declarations = .init()
		) {
			self.conflicts						= conflicts
			self.possiblyLiveLocations			= possiblyLiveLocations
			self.definedLocations				= definedLocations
			self.possiblyUsedUndefinedLocations	= possiblyUsedUndefinedLocations
			self.declarations					= declarations
		}
		
		/// The conflict set.
		///
		/// The conflict set grows while traversing a program in reverse order. A location that is defined conflicts with all locations (except itself) that are marked as possibly used at the time.
		public private(set) var conflicts: ConflictSet
		
		/// The locations whose values are possibly used by a successor.
		///
		/// This set grows and shrinks while traversing a program in reverse order. A location that is defined is removed from the set whereas a location that is used is added to the set.
		public private(set) var possiblyLiveLocations: Set<Location>
		
		/// The locations that are defined by a successor.
		///
		/// This set grows while traversing a program (in either order). A location that is defined is added to this set.
		public private(set) var definedLocations: Set<Location>
		
		/// The locations that are possibly used by a successor but not defined by a successor.
		///
		/// This set grows and shrinks while traversing a program in reverse order. A location that is defined is removed from the set whereas a location that is used and not in `definedLocations` is added to the set.
		///
		/// An *undefined use* error is thrown during lowering if this set is nonempty at a push-scope effect's entry.
		public private(set) var possiblyUsedUndefinedLocations: Set<Location>
		
		/// The type assignments of any locations used or defined by a successor.
		public private(set) var declarations: Declarations
		
		/// Updates the analysis with information about an effect or predicate.
		///
		/// - Parameters:
		///    - defined: The (typed) locations that are defined by the effect.
		///    - possiblyUsed: The (typed) locations that are (possibly) used by the effect or predicate.    
		mutating func update<D : Sequence, U : Sequence>(defined: D, possiblyUsed: U) throws where D.Element == TypedLocation, U.Element == TypedLocation {
			
			let possiblyLiveLocationsAtExit = possiblyLiveLocations
			markAsDefinitelyDiscarded(defined.lazy.map(\.location))
			markAsPossiblyUsedLater(possiblyUsed.lazy.map(\.location))	// a self-copy (both "discarded" & "used") is considered possibly used, so add used after discarded
			for definedLocation in defined.lazy.map(\.location) {
				insertConflict(definedLocation, possiblyLiveLocationsAtExit)
			}
			
			definedLocations.formUnion(defined.lazy.map(\.location))
			possiblyUsedUndefinedLocations.formUnion(possiblyUsed.lazy.map(\.location))
			possiblyUsedUndefinedLocations.subtract(definedLocations)
			
			for location in defined {
				try declarations.insert(location)
			}
			for location in possiblyUsed {
				try declarations.insert(location)
			}
			
		}
		
		/// Returns a copy of `self` with additional information about an effect or predicate applied to it.
		///
		/// - Parameters:
		///    - defined: The (typed) locations that are defined by the effect.
		///    - possiblyUsed: The (typed) locations that are (possibly) used by the effect or predicate.
		func updated<D : Sequence, U : Sequence>(defined: D, possiblyUsed: U) throws -> Self where D.Element == TypedLocation, U.Element == TypedLocation {
			var copy = self
			try copy.update(defined: defined, possiblyUsed: possiblyUsed)
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
