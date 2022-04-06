// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension CC {
	
	/// A value used while lowering a procedure.
	struct Context {
		
		/// Creates a context value.
		init(procedures: [Procedure], configuration: CompilationConfiguration) {
			self.procedures = procedures
			self.configuration = configuration
		}
		
		/// The program's procedures.
		let procedures: [Procedure]
		
		/// The procedure being lowered, or `nil` if no procedure is being lowered.
		var loweredProcedure: Procedure? = nil
		
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
		
		/// A mapping from locations to procedure sign.
		private var procedureSignaturesByLocation = [Location : ProcedureSignature]()
		typealias ProcedureSignature = ([Parameter], ValueType)
		
		/// Declares `location` to be typed `type`.
		mutating func declare(_ location: Location, _ type: ValueType) throws {
			guard case .cap(.procedure(takes: let parameters, returns: let resultType)) = type else { return }
			if let previous = procedureSignaturesByLocation.updateValue((parameters, resultType), forKey: location) {
				throw TypingError.multipleTypes(
					location,
					.cap(.procedure(takes: previous.0, returns: previous.1)),
					.cap(.procedure(takes: parameters, returns: resultType))
				)
			}
		}
		
		/// Declares `location` to be typed the same as `source`.
		mutating func declare(_ location: Location, sameTypeAs source: Source) throws {
			switch source {
				
				case .constant:
				procedureSignaturesByLocation[location] = nil
				
				case .location(let source):
				procedureSignaturesByLocation[location] = procedureSignaturesByLocation[source]
				
				case .procedure(let name):
				guard let procedure = procedures[name] else { throw TypingError.unrecognisedProcedure(name: name) }
				procedureSignaturesByLocation[location] = (procedure.parameters, procedure.resultType)
				
			}
		}
		
		/// Returns the signature of the procedure in given location.
		func signature(of location: Location) throws -> ProcedureSignature {
			guard let signature = procedureSignaturesByLocation[location] else { throw TypingError.nonprocedureLocation(location) }
			return signature
		}
		
		/// Returns the signature of the procedure.
		func signature(of source: Source) throws -> ProcedureSignature {
			switch source {
				
				case .constant:
				throw TypingError.nonprocedureSource(source)
				
				case .location(let location):
				return try signature(of: location)
				
				case .procedure(let name):
				guard let procedure = procedures[name] else { throw TypingError.unrecognisedProcedure(name: name) }
				return (procedure.parameters, procedure.resultType)
				
			}
		}
		
	}
	
	private enum TypingError : LocalizedError {
		
		/// An error indicating that given source does not refer to a procedure.
		case nonprocedureSource(Source)
		
		/// An error indicating that given location is not declared or a procedure location.
		case nonprocedureLocation(Location)
		
		/// An error indicating that no procedure is known by the name `name`.
		case unrecognisedProcedure(name: Label)
		
		/// An error indicating that given location is typed as two different value types.
		case multipleTypes(Location, ValueType, ValueType)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				
				case .nonprocedureSource(let source):
				return "\(source) does not refer to a procedure"
				
				case .nonprocedureLocation(let location):
				return "“\(location)” is not declared or a procedure location"
				
				case .multipleTypes(let location, let firstType, let otherType):
				return "“\(location)” is typed as \(firstType) and \(otherType)"
				
				case .unrecognisedProcedure(name: let name):
				return "Unrecognised procedure “\(name)”"
				
			}
		}
		
	}
	
}
