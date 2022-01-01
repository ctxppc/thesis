// Glyco © 2021–2022 Constantino Tsarouhas

import Algorithms
import DepthKit

extension AL {
	
	/// An abstract storage location on an AL machine.
	public struct Location : RawCodable, Hashable, SimplyLowerable {
		
		// See protocol.
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		
		/// The identifier.
		public var rawValue: String
		
		// See protocol.
		func lowered(in context: inout LocalContext) -> Lower.Location {
			context.assignments[self]
		}
		
		/// A value that assigns locations to homes.
		struct Assignments {
			
			/// Determines an assignment using given procedure parameters and conflict graph.
			///
			/// The initialiser first assigns homes for each parameter, according to the active calling convention, then assigns homes to all used locations, by increasing degree of conflict.
			init(parameters: [Procedure.Parameter], conflicts: ConflictGraph, argumentRegisters: [Lower.Register]) {
				
				self.conflicts = conflicts
				
				let argumentRegisters = chain(argumentRegisters.lazy.map { $0 }, [nil].cycled())
				for (parameter, register) in zip(parameters, argumentRegisters) {
					switch parameter {
						case .parameter(let location, type: let type):
						let home: Lower.Location
						if let register = register {
							home = .register(register)
							locationsByRegister[register, default: []].insert(location)
						} else {
							home = .frameCell(frame.allocate(type))
						}
						homesByLocation[location] = home
					}
				}
				
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
			
			/// Returns a register that `location` can be assigned to, or `nil` if no register is available.
			private func assignableRegister(for location: Location) -> Lower.Register? {
				Lower.Register.assignableRegisters.first { register in
					guard let assignedLocations = locationsByRegister[register] else { return true }
					return !conflicts.containsConflict(location, assignedLocations)
				}
			}
			
		}
		
	}
	
}

extension AL.Location : Comparable {
	public static func <(earlier: Self, later: Self) -> Bool {
		earlier.rawValue < later.rawValue
	}
}
