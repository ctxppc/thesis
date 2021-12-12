// Glyco © 2021 Constantino Tsarouhas

import DepthKit

extension AL {
	
	/// An abstract storage location on an AL machine.
	public enum Location : Codable, Hashable, Comparable, SimplyLowerable {
		
		/// A location with given procedure-wide identifier.
		case location(Int)
		
		// See protocol.
		func lowered(in context: inout Context) -> Lower.Location {
			context.assignments[self]
		}
		
		/// A value that assigns locations to homes.
		struct Assignments {
			
			/// Determines an assignment using given conflict graph.
			init(conflicts: ConflictGraph) {
				self.conflicts = conflicts
				for location in conflicts.locationsOrderedByIncreasingNumberOfConflicts() {
					addAssignment(for: location)
				}
			}
			
			/// Returns `location`'s assigned physical location.
			subscript (location: Location) -> Lower.Location {
				mutating get {
					guard let home = homesByLocation[location] else { return addAssignment(for: location) }
					return home
				}
			}
			
			/// The conflict graph.
			private let conflicts: ConflictGraph
			
			/// A mapping from abstract locations to physical locations.
			private var homesByLocation = [Location : Lower.Location]()
			
			/// A mapping from registers to locations assigned to that register.
			private var locationsByRegister = [Lower.Register : Set<Location>]()
			
			/// The frame on which spilled data are stored.
			private var frame = Lower.Frame()
			
			/// Adds an assignment for `location` and returns the assigned physical location.
			@discardableResult
			private mutating func addAssignment(for location: Location) -> Lower.Location {
				let home: Lower.Location
				if let register = assignableRegister(for: location) {
					home = .register(register)
					locationsByRegister[register, default: []].insert(location)
				} else {
					home = .frameCell(frame.allocate(.word))
				}
				homesByLocation[location] = home
				return home
			}
			
			/// Returns a register that `location` can be assigned, or `nil` if no register is available.
			private func assignableRegister(for location: Location) -> Lower.Register? {
				Lower.Register.assignableRegisters.first { register in
					guard let assignedLocations = locationsByRegister[register] else { return true }
					return !conflicts.containsConflict(location, assignedLocations)
				}
			}
			
		}
		
	}
	
}

extension AL.Location : CustomStringConvertible {
	public var description: String {
		switch self {
			case .location(id: let id):	return "aloc\(id)"
		}
	}
}
