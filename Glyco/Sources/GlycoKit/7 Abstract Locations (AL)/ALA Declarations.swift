// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension ALA {
	
	//sourcery: hasOpaqueRepresentation
	/// A list of defined typed locations.
	public struct Declarations : Equatable {
		
		//sourcery: isInternalForm
		/// Creates an empty definitions list.
		public init() {}
		
		/// Creates a definitions list with given typed locations.
		public init(_ locations: [TypedLocation]) throws {
			for location in locations {
				try insert(location)
			}
		}
		
		/// A mapping from locations to value types.
		///
		/// - Invariant: No location in the mapping represents a registers.
		private var typesByLocation = [Location : ValueType]()
		
		/// Accesses the type for given location.
		///
		/// Since registers cannot be assigned a type, the getter throws an unknown type error if `location` represents a register.
		public subscript (location: Location) -> ValueType {
			get throws {
				guard let type = typesByLocation[location] else { throw TypeError.unknownType(location) }
				return type
			}
		}
		
		/// Accesses the (widest supported) value type for given source.
		public subscript (source: Source) -> ValueType {
			get throws {
				switch source {
					case .constant:					return .signedWord
					case .abstract(let location):	return try self[Location.abstract(location)]
					case .register(_, let type):	return type
					case .frame(let location):		return try self[Location.frame(location)]
				}
			}
		}
		
		/// Declares given location and assigns it given type.
		///
		/// Since registers cannot be assigned a type, this method does nothing if `location` represents a register.
		public mutating func declare(_ location: Location, type newType: ValueType) throws {
			
			if case .register = location { return }
			
			let previousType = typesByLocation.updateValue(newType, forKey: location)
			if let previousType = previousType, previousType != newType {
				throw TypeError.inconsistentTyping(location, previousType, newType)
			}
			
		}
		
		/// Requires given location to be declared and typed `requiredType`.
		public func require(_ location: Location, type requiredType: ValueType) throws {
			if let previousType = typesByLocation[location], previousType != requiredType {
				throw TypeError.inconsistentTyping(location, previousType, requiredType)
			}
		}
		
		/// Requires given source to be typed `requiredType`, and if it represents a location, that location to be declared.
		public func require(_ source: Source, type requiredType: ValueType) throws {
			switch source {
				
				case .constant(let value):
				guard requiredType.supports(constant: value) else { throw TypeError.constantNotRepresentableByType(value, requiredType) }
				
				case .abstract(let location):
				try require(Location.abstract(location), type: requiredType)
				
				case .register(let register, let type):
				guard requiredType == type else { throw TypeError.inconsistentTyping(.register(register), type, requiredType) }
				
				case .frame(let location):
				try require(Location.frame(location), type: requiredType)
				
			}
		}
		
		/// Returns the element type for given vector location.
		public func elementType(vector: Location) throws -> ValueType {
			guard case .capability(let elementType) = try self[vector] else { throw TypeError.noVectorType(vector) }
			return elementType
		}
		
		/// Removes given location.
		public mutating func remove(_ location: Location) {
			typesByLocation.removeValue(forKey: location)
		}
		
		/// Inserts given typed location to the assignment.
		///
		/// - Throws: An inconsistent typing error if `self` contains a value type for the same location that is different than `typedLocation`'s value type.
		mutating func insert(_ typedLocation: TypedLocation) throws {	// TODO: Remove?
			guard let newType = typedLocation.valueType else { return }
			let previousType = typesByLocation.updateValue(newType, forKey: typedLocation.location)
			if let previousType = previousType, previousType != newType {
				throw TypeError.inconsistentTyping(typedLocation.location, previousType, newType)
			}
		}
		
		/// Accesses the typed location associated with `location`.
		subscript (location: Location) -> TypedLocation {	// TODO: Remove?
			.init(location: location, dataType: typesByLocation[location])
		}
		
		enum TypeError : LocalizedError {
			
			/// An error indicating that the value type of given location cannot be determined.
			case unknownType(Location)
			
			/// An error indicating that given constant cannot be represented by a value of given type.
			case constantNotRepresentableByType(Int, ValueType)
			
			/// An error indicating given location is not a vector type.
			case noVectorType(Location)
			
			/// An error indicating that given location is bound to different value types.
			case inconsistentTyping(Location, ValueType, ValueType)
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					
					case .unknownType(let location):
					return "No known type for “\(location)”"
					
					case .constantNotRepresentableByType(let value, let type):
					return "\(value) cannot be represented by a value typed \(type)"
					
					case .noVectorType(let location):
					return "“\(location)” is not a vector type"
					
					case .inconsistentTyping(let location, let firstType, let otherType):
					return "“\(location)” is simultaneously typed \(firstType) and \(otherType)"
					
				}
			}
			
		}
		
	}
	
}

extension ALA.Declarations : Codable {
	
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
