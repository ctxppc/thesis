// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension ALA {
	
	//sourcery: hasOpaqueRepresentation
	/// A mapping from locations to data types.
	public struct TypeAssignments : Equatable {
		
		//sourcery: isInternalForm
		/// Creates an empty mapping.
		public init() {}
		
		/// Creates a mapping with given typed locations.
		public init(_ locations: [TypedLocation]) throws {
			for location in locations {
				try insert(location)
			}
		}
		
		/// A mapping from locations to data types.
		private var typesByLocation = [Location : DataType]()
		
		/// Accesses the type for given location.
		public subscript (location: Location) -> DataType {
			get throws {
				guard let type = typesByLocation[location] else { throw TypeError.unknownType(location) }
				return type
			}
		}
		
		/// Accesses the type for given location.
		public subscript (source: Source) -> DataType {
			get throws {
				switch source {
					case .constant:					return .signedWord
					case .abstract(let location):	return try self[Location.abstract(location)]
					case .register(_, let type):	return type
					case .frame(let location):		return try self[Location.frame(location)]
				}
			}
		}
		
		/// Assigns given type to given location.
		public mutating func assign(_ newType: DataType, to location: Location) throws {
			let previousType = typesByLocation.updateValue(newType, forKey: location)
			if let previousType = previousType, previousType != newType {
				throw TypeError.inconsistentTyping(location, previousType, newType)
			}
		}
		
		/// Inserts given typed location to the assignment.
		///
		/// - Throws: An inconsistent typing error if `self` contains a type for the same location that is different than `typedLocation`'s type.
		mutating func insert(_ typedLocation: TypedLocation) throws {
			guard let newType = typedLocation.dataType else { return }
			let previousType = typesByLocation.updateValue(newType, forKey: typedLocation.location)
			if let previousType = previousType, previousType != newType {
				throw TypeError.inconsistentTyping(typedLocation.location, previousType, newType)
			}
		}
		
		/// Accesses the typed location associated with `location`.
		subscript (location: Location) -> TypedLocation {
			.init(location: location, dataType: typesByLocation[location])
		}
		
		enum TypeError : LocalizedError {
			
			/// An error indicating that the type of given location cannot be determined.
			case unknownType(Location)
			
			/// An error indicating that given locations is simultaneously bound to two given different data types.
			case inconsistentTyping(Location, DataType, DataType)
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					
					case .unknownType(let location):
					return "No known type for “\(location)”"
					
					case .inconsistentTyping(let location, let firstType, let otherType):
					return "“\(location)” is simultaneously typed \(firstType) and \(otherType)"
					
				}
			}
			
		}
		
	}
	
}

extension ALA.TypeAssignments : Codable {
	
	//sourcery: isInternalForm
	public init(from decoder: Decoder) throws {
		try self.init(decoder.singleValueContainer().decode([ALA.TypedLocation].self))
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(
			typesByLocation.map { ALA.TypedLocation(location: $0.key, dataType: $0.value) }
		)
	}
	
}
