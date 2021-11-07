// Glyco © 2021 Constantino Tsarouhas

import DepthKit

extension AL {
	
	/// An abstract storage location on an AL machine.
	public struct Location : Codable, Hashable, RawRepresentable, SimplyLowerable {
		
		/// Creates a location.
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
		
		// See protocol.
		public let rawValue: Int
		
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
				homesByLocation[location] !! "Expected assignment of \(location) to a physical location"
			}
			
			/// The conflict graph.
			private let conflicts: ConflictGraph
			
			/// A mapping from abstract locations to physical locations.
			private var homesByLocation = [Location : Lower.Location]()
			
			/// A mapping from registers to locations assigned to that register.
			private var locationsByRegister = [Lower.Register : Set<Location>]()
			
			/// The frame on which spilled data are stored.
			private var frame = Lower.Frame()
			
			/// Adds an assignment for `location`.
			private mutating func addAssignment(for location: Location) {
				if let register = assignableRegister(for: location) {
					homesByLocation[location] = .register(register)
					locationsByRegister[register, default: []].insert(location)
				} else {
					homesByLocation[location] = .frameCell(frame.allocate(.word))
				}
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
		"\(rawValue)"
	}
}
