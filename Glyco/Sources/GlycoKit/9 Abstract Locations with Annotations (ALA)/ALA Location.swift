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
				case .frame(let location):		return .frame(location)
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
				
				let partition = analysisAtScopeEntry.conflicts.degreePartition
				let locationsOrderedByDegree = declarations
					.map(\.location)
					.sorted(by: { (partition[$0], $0) < (partition[$1], $1) })
				for location in locationsOrderedByDegree {
					guard case .abstract(let location) = location else { continue }
					try addAssignment(for: location)
				}
				
			}
			
			/// Returns `location`'s assigned physical location.
			subscript (location: AbstractLocation) -> Lower.Location {
				get throws {
					guard let home = homesByLocation[location] else { throw Error.undeclaredLocation(location) }
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
			///
			/// - Invariant: Every register location is assigned to its corresponding register.
			private var locationsByRegister: [Lower.Register : Set<Location>] = .init(
				uniqueKeysWithValues: Lower.Register.allCases.lazy.map { ($0, [.register($0)]) }
			)
			
			/// The frame on which spilled data are stored.
			private(set) var frame = Lower.Frame.initial
			
			/// Assigns a physical location to `location`.
			private mutating func addAssignment(for location: AbstractLocation) throws {
				let home: Lower.Location
				if let register = assignableRegister(for: location) {
					home = .register(register)
					locationsByRegister[register, default: []].insert(.abstract(location))
				} else {
					home = .frame(frame.allocate(try declarations.type(of: Location.abstract(location))))
				}
				homesByLocation[location] = home
			}
			
			/// Returns a register that `location` can be assigned to, or `nil` if no register is available.
			private func assignableRegister(for location: AbstractLocation) -> Lower.Register? {
				Lower.Register.assignableRegisters.first { register in
					!analysisAtScopeEntry.conflicts.contains(
						.abstract(location),
						locationsByRegister[register] !! "Register location \(register) not assigned to physical location \(register)"
					)
				}
			}
			
			enum Error : LocalizedError {
				
				/// An error indicating that given referenced location is not declared.
				case undeclaredLocation(AbstractLocation)
				
				// See protocol.
				var errorDescription: String? {
					switch self {
						case .undeclaredLocation(let location):
						return "“\(location)” is referenced but not declared"
					}
				}
				
			}
			
		}
		
	}
	
}
