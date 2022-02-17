// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit
import Foundation

extension ALA {
	
	/// A location.
	public enum Location : Codable, Hashable, Comparable, SimplyLowerable {
		
		/// An abstract location, to be lowered to a physical location after register allocation.
		case abstract(AbstractLocation)
		
		/// A location fixed to given register.
		case register(Register)
		
		/// A location fixed to given frame location.
		case frame(Frame.Location)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Location {
			switch self {
				case .abstract(let location):	return try location.lowered(in: &context)
				case .register(let register):	return .register(register)
				case .frame(let location):		return .frameCell(location)
			}
		}
		
		/// A Boolean value indicating whether `self` is a physical location.
		var isPhysical: Bool {
			switch self {
				case .abstract:			return false
				case .register, .frame:	return true
			}
		}
		
		/// A mapping from abstract locations to physical locations.
		struct Assignments {
			
			/// Determines an assignment using given analysis at the scope's entry.
			///
			/// The initialiser assigns homes to all used locations, by increasing degree of conflict.
			init(declarations: Declarations, analysisAtScopeEntry: Analysis) throws {
				self.declarations = declarations
				self.analysisAtScopeEntry = analysisAtScopeEntry
				for location in analysisAtScopeEntry.locationsOrderedByIncreasingNumberOfConflicts() {
					guard case .abstract(let location) = location else { continue }
					try addAssignment(for: location)
				}
			}
			
			/// Returns `location`'s assigned physical location.
			subscript (location: AbstractLocation) -> Lower.Location {
				mutating get throws {
					guard let home = homesByLocation[location] else { return try addAssignment(for: location) }
					return home
				}
			}
			
			/// The declarations.
			let declarations: Declarations
			
			/// The analysis at the scope's entry.
			let analysisAtScopeEntry: Analysis
			
			/// A mapping from abstract locations to physical locations.
			private var homesByLocation = [AbstractLocation : Lower.Location]()
			
			/// A mapping from registers to locations assigned to that register.
			private var locationsByRegister = [Lower.Register : Set<Location>]()
			
			/// The frame on which spilled data are stored.
			private(set) var frame = Lower.Frame.initial
			
			/// Adds an assignment for `location` and returns the assigned physical location.
			@discardableResult
			private mutating func addAssignment(for location: AbstractLocation) throws -> Lower.Location {
				let home: Lower.Location
				if let register = assignableRegister(for: location) {
					home = .register(register)
					locationsByRegister[register, default: []].insert(.abstract(location))
				} else {
					home = .frameCell(frame.allocate(try declarations.type(of: Location.abstract(location))))
				}
				homesByLocation[location] = home
				return home
			}
			
			/// Returns a register that `location` can be assigned to, or `nil` if no register is available.
			private func assignableRegister(for location: AbstractLocation) -> Lower.Register? {
				Lower.Register.defaultAssignableRegisters.first { register in
					guard let assignedLocations = locationsByRegister[register] else { return true }
					return !analysisAtScopeEntry.conflicts.contains(.abstract(location), assignedLocations)
				}
			}
			
		}
		
	}
	
}
