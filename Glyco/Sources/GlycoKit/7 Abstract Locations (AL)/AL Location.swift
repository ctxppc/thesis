// Glyco © 2021–2022 Constantino Tsarouhas

extension AL {
	
	/// A location.
	public enum Location : Codable, Hashable, Comparable, SimplyLowerable {
		
		case abstract(AbstractLocation)
		case parameter(ParameterLocation)
		
		// See protocol.
		func lowered(in context: inout LocalContext) throws -> Lower.Location {
			switch self {
				case .abstract(let location):	return location.lowered(in: &context)
				case .parameter(let location):	return try location.lowered(in: &context)
			}
		}
		
		/// A value that assigns locations to physical locations.
		struct Assignments {
			
			/// Determines an assignment using given conflict graph.
			///
			/// The initialiser assigns homes to all used locations, by increasing degree of conflict.
			init(conflicts: ConflictGraph) {
				self.conflicts = conflicts
				for location in conflicts.locationsOrderedByIncreasingNumberOfConflicts() {
					guard case .abstract(let location) = location else { continue }
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
			private var locationsByRegister = [Lower.Register : Set<Location>]()
			
			/// The frame on which spilled data are stored.
			private var frame = Lower.Frame()
			
			/// Adds an assignment for `location` and returns the assigned physical location.
			@discardableResult
			private mutating func addAssignment(for location: AbstractLocation) -> Lower.Location {
				let home: Lower.Location
				if let register = assignableRegister(for: location) {
					home = .register(register)
					locationsByRegister[register, default: []].insert(.abstract(location))
				} else {
					home = .frameCell(frame.allocate(.word))
				}
				homesByLocation[location] = home
				return home
			}
			
			/// Returns a register that `location` can be assigned to, or `nil` if no register is available.
			private func assignableRegister(for location: AbstractLocation) -> Lower.Register? {
				Lower.Register.assignableRegisters.first { register in
					guard let assignedLocations = locationsByRegister[register] else { return true }
					return !conflicts.containsConflict(.abstract(location), assignedLocations)
				}
			}
			
		}
		
	}
	
}
