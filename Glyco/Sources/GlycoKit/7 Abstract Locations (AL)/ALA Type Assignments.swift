// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension ALA {
	
	//sourcery: hasOpaqueRepresentation
	/// A mapping from locations to data types.
	public struct TypeAssignments : Equatable {
		
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
		
		/// Inserts given typed location to the assignment.
		///
		/// - Throws: An inconsistent
		mutating func insert(_ typedLocation: TypedLocation) throws {
			let previous = typesByLocation.updateValue(typedLocation.dataType, forKey: typedLocation.location)
			if let previous = previous, previous != typedLocation.dataType {
				throw TypeError.inconsistentTyping(typedLocation.location, previous, typedLocation.dataType)
			}
		}
		
		/// Accesses the typed location associated with `location`.
		subscript (location: Location) -> TypedLocation? {
			typesByLocation[location]
				.map { .init(location: location, dataType: $0) }
		}
		
		enum TypeError : LocalizedError {
			
			/// An error indicating that given locations is simultaneously bound to two given different data types.
			case inconsistentTyping(Location, DataType, DataType)
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					case .inconsistentTyping(let location, let firstType, let otherType):
					return "“\(location)” is simultaneously typed \(firstType) and \(otherType)"
				}
			}
			
		}
		
	}
	
	/// A location with an associated data type.
	public struct TypedLocation : Equatable, Codable {
		
		/// The location.
		var location: Location
		
		/// The location's data type.
		var dataType: DataType
		
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
