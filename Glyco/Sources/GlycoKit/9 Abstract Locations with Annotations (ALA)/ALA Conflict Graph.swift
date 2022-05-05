// Glyco © 2021–2022 Constantino Tsarouhas

import Algorithms
import DepthKit

extension ALA {
	
	/// A graph of locations where locations that may have different values in some execution paths are connected, i.e., they *conflict*.
	///
	/// Physical locations always conflict with all other physical locations. These conflicts are not explicitated in the graph but is encoded in `contains(_:_:)`.
	public struct ConflictGraph : Element {
		
		/// Creates a graph with given conflicts.
		public init(_ conflicts: [Conflict]) {
			for conflict in conflicts {
				insert(conflict.first, conflict.second)
			}
		}
		
		/// A mapping from locations to locations that conflict with the former.
		///
		/// - Invariant: The mapping is symmetric, i.e., for every location `a` and `b`, if `conflictingLocationsForLocation[a]!.contains(b)` then `conflictingLocationsForLocation[b]!.contains(a)`.
		private var conflictingLocationsForLocation: [Location : Set<Location>] = [:]
		
		/// The graph's conflicts.
		var conflicts: Set<Conflict> {
			var conflicts = Set<Conflict>()
			for (firstLocation, otherLocations) in conflictingLocationsForLocation {
				for otherLocation in otherLocations {
					guard !conflicts.contains(.init(otherLocation, firstLocation)) else { continue }
					conflicts.insert(.init(firstLocation, otherLocation))
				}
			}
			return conflicts
		}
		
		/// Inserts a conflict between given locations to the graph.
		///
		/// This method does nothing if `firstLocation` and `otherLocation` are equal or are both physical locations. Locations cannot conflict with themselves; physical locations implictly conflict with all other physical locations.
		mutating func insert(_ firstLocation: Location, _ otherLocation: Location) {
			guard firstLocation != otherLocation else { return }
			if firstLocation.isPhysical && otherLocation.isPhysical { return }
			conflictingLocationsForLocation[firstLocation, default: []].insert(otherLocation)
			conflictingLocationsForLocation[otherLocation, default: []].insert(firstLocation)
		}
		
		/// Adds conflicts between `firstLocation` and `otherLocations`.
		///
		/// This method does not add a conflict between a location and itself.
		mutating func insert(between firstLocation: Location, and otherLocations: Set<Location>) {
			for otherLocation in otherLocations {
				insert(firstLocation, otherLocation)
			}
		}
		
		/// Returns a Boolean value indicating whether the graph contains a conflict between `firstLocation` and any location in `otherLocations`.
		func contains(_ firstLocation: Location, _ otherLocations: Set<Location>) -> Bool {
			if firstLocation.isPhysical && otherLocations.contains(where: \.isPhysical) { return true }
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
			
			guard !contains(firstLocation, [otherLocation]) else { return false }
			
			// Apply (conservative) heuristic by Briggs et al. to avoid turning a K-colourable conflict graph into non-K-colourable.
			let conflictingLocationsOfUnion = conflictingLocationsForLocation[firstLocation, default: []]
				.union(conflictingLocationsForLocation[otherLocation, default: []])
				.subtracting([firstLocation, otherLocation])
			return conflictingLocationsOfUnion.count /* new conflict count */ < Lower.Register.assignableRegisters.count /* K */
			
		}
		
		/// A partition of locations in by conflict degree in `self`.
		var degreePartition: DegreePartition { .init(from: self) }
		
		/// A partition of locations by conflict degree (number of conflicts).
		struct DegreePartition {
			
			/// Creates a degree partition from given graph.
			fileprivate init(from graph: ConflictGraph) {
				degreesByLocation = graph.conflictingLocationsForLocation.mapValues(\.count)
			}
			
			/// Accesses the degree of given location.
			subscript (location: Location) -> Int {
				degreesByLocation[location] ?? 0
			}
			
			private let degreesByLocation: [Location : Int]
			
		}
		
	}
	
}

extension ALA.ConflictGraph : Codable {
	
	//sourcery: isInternalForm
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.init(try container.decode(key: .conflicts))
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(conflicts.sorted(), forKey: .conflicts)	// ensure deterministic ordering by sorting
	}
	
}
