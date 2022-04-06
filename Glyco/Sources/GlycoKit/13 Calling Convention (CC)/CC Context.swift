// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension CC {
	
	/// A value used while lowering a program or procedure.
	struct Context {
		
		/// Creates a context value.
		init(procedures: [Procedure], loweredProcedure: Procedure?, configuration: CompilationConfiguration) {
			self.procedures = procedures
			self.loweredProcedure = loweredProcedure
			self.configuration = configuration
		}
		
		/// The program's procedures.
		let procedures: [Procedure]
		
		/// The procedure being lowered, or `nil` if no procedure is being lowered.
		let loweredProcedure: Procedure?
		
		/// The compilation configuration.
		let configuration: CompilationConfiguration
		
		/// The abstract locations bag.
		var locations = Bag<Lower.AbstractLocation>()
		
		/// Returns the location for given saved register.
		mutating func saveLocation(for register: Lower.Register) -> Lower.AbstractLocation {
			if let location = saveLocationByRegister[register] {
				return location
			} else {
				let location = locations.uniqueName(from: "saved\(register.rawValue.uppercased())")
				saveLocationByRegister[register] = location
				return location
			}
		}
		
		/// The locations by saved register.
		private var saveLocationByRegister = [Lower.Register : Lower.AbstractLocation]()
		
		/// The location of the return capability.
		private(set) lazy var returnLocation = locations.uniqueName(from: "retcap")
		
		/// A mapping from locations to value types.
		private var valueTypesByLocation = [Location : ValueType]()
		
		/// Declares `location` to be typed `type`.
		mutating func declare(_ location: Location, _ type: ValueType) throws {
			if let previous = valueTypesByLocation.updateValue(type, forKey: location), previous != type {
				throw TypingError.multipleTypes(location, previous, type)
			}
		}
		
		/// Determines the value type of given location.
		func type(of location: Location) throws -> ValueType {
			guard let valueType = valueTypesByLocation[location] else { throw TypingError.unknownType(location) }
			return valueType
		}
		
		/// Determines the value type of given source.
		func type(of source: Source) throws -> ValueType {
			switch source {
				
				case .constant:
				return .s32
				
				case .location(let location):
				return try type(of: location)
				
				case .procedure(let name):
				guard let procedure = procedures[name] else { throw TypingError.unrecognisedProcedure(name: name) }
				return .cap(.procedure(takes: procedure.parameters, returns: procedure.resultType))
				
			}
		}
		
	}
	
	private enum TypingError : LocalizedError {
		
		/// An error indicating that the value type of given location cannot be determined.
		case unknownType(Location)
		
		/// An error indicating that no procedure is known by the name `name`.
		case unrecognisedProcedure(name: Label)
		
		/// An error indicating that given location is typed as two different value types.
		case multipleTypes(Location, ValueType, ValueType)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				
				case .unknownType(let location):
				return "No known type for “\(location)”"
				
				case .unrecognisedProcedure(name: let name):
				return "Unrecognised procedure “\(name)”"
				
				case .multipleTypes(let location, let firstType, let otherType):
				return "“\(location)” is typed as \(firstType) and \(otherType)"
				
			}
		}
		
	}
	
}
