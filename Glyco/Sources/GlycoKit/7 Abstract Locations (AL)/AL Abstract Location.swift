// Glyco © 2021 Constantino Tsarouhas

import DepthKit

extension AL {
	
	/// A location that is to be assigned a physical location.
	public struct AbstractLocation : Codable, Hashable, RawRepresentable {
		
		/// Creates a location.
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
		
		// See protocol.
		public let rawValue: Int
		
		/// A value that assigns abstract locations to physical locations.
		struct Assignments {
			
			/// Determines an assignment using given conflict graph.
			init(conflicts: ConflictGraph) {
				self.conflicts = conflicts
				for location in conflicts.locationsOrderedByIncreasingNumberOfConflicts() {
					addAssignment(for: location)
				}
			}
			
			/// Returns `location`'s assigned physical location.
			subscript (location: AbstractLocation) -> Lower.Location {
				mutating get {
					guard let home = homesByLocation[location] else { return addAssignment(for: location) }
					return home
				}
			}
			
			/// The conflict graph.
			private let conflicts: ConflictGraph
			
			/// A mapping from abstract locations to physical locations.
			private var homesByLocation = [AbstractLocation : Lower.Location]()
			
			/// A mapping from registers to locations assigned to that register.
			private var locationsByRegister = [Lower.Register : Set<AbstractLocation>]()
			
			/// The frame on which spilled data are stored.
			private var frame = Lower.Frame()
			
			/// Adds an assignment for `location` and returns the assigned physical location.
			@discardableResult
			private mutating func addAssignment(for location: AbstractLocation) -> Lower.Location {
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
			private func assignableRegister(for location: AbstractLocation) -> Lower.Register? {
				Lower.Register.assignableRegisters.first { register in
					guard let assignedLocations = locationsByRegister[register] else { return true }
					return !conflicts.containsConflict(location, assignedLocations)
				}
			}
			
		}
		
	}
	
}

extension AL.AbstractLocation : CustomStringConvertible {
	public var description: String {
		"aloc\(rawValue)"
	}
}
