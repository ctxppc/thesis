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
			for typedLocation in locations {
				try declare(typedLocation.location, type: typedLocation.dataType)
			}
		}
		
		/// A mapping from locations to data types.
		///
		/// - Invariant: No location in the mapping represents a registers.
		private var typesByLocation = [Location : DataType]()
		
		/// Returns given location's declared data type.
		///
		/// If a register location is given, an unknown-type error is thrown since registers cannot have a fixed value type.
		///
		/// - Parameter location: The location whose type to determine.
		///
		/// - Returns: The data type of `location`.
		public func type(of location: Location) throws -> DataType {
			guard let type = typesByLocation[location] else { throw TypeError.unknownType(location) }
			return type
		}
		
		/// Returns given locations' declared data type.
		///
		/// The behaviour of this method depends on the kind of locations that are provided.
		/// * If no non-register locations are given, an unknown-type error is thrown since registers cannot have a fixed data type.
		/// * If exactly one non-register location is given, it determines the data type.
		/// * If two non-register locations are given, both determine the data type and an error is thrown if either one doesn't have a data type or if they have different data types.
		///
		/// - Parameters:
		///   - location: The location whose data type to determine.
		///   - otherLocation: A location with the same data type as `location`.
		///
		/// - Returns: The data type of `location`, and `otherLocation`.
		public func type(of location: Location, and otherLocation: Location) throws -> DataType {
			switch (location, otherLocation) {
				
				case (.register, .register):
				throw TypeError.unknownType(location)
				
				case (.register, let location), (let location, .register):
				return try type(of: location)
				
				case (let location, let otherLocation):
				let type = try self.type(of: location)
				let otherType = try self.type(of: otherLocation)
				guard type == otherType else { throw TypeError.unequalTypes(location ~ type, otherLocation ~ otherType) }
				return type
				
			}
		}
		
		/// Returns given source's (widest supported) value type.
		public func type(of source: Source) throws -> DataType {
			switch source {
				case .constant:					return .s32
				case .abstract(let location):	return try type(of: Location.abstract(location))
				case .register(_, let type):	return type
				case .frame(let location):		return try type(of: Location.frame(location))
			}
		}
		
		/// Returns the data type of given location and source.
		///
		/// The behaviour of this method depends on the kind of location and source that are provided.
		///
		/// - Parameters:
		///   - location: The location whose data type to determine.
		///   - otherLocation: A location with the same data type as `location`.
		///
		/// - Returns: The data type of `location`, and `otherLocation`.
		public func type(of location: Location, and source: Source) throws -> DataType {
			
			if case .register = location {
				return try type(of: source)
			}
			
			switch source {
				
				case .constant(let value):
				let locationType = try type(of: location)
				guard locationType.supports(constant: value) else { throw TypeError.constantNotRepresentableByType(value, locationType) }
				return locationType
				
				case .abstract(let abstractLocation):
				return try type(of: location, and: Location.abstract(abstractLocation))
				
				case .frame(let frameLocation):
				return try type(of: location, and: Location.frame(frameLocation))
				
				case .register(let register, let sourceType):
				let locationType = try type(of: location)
				guard locationType == sourceType else { throw TypeError.unequalTypes(location ~ locationType, .register(register) ~ sourceType) }
				return locationType
				
			}
			
		}
		
		/// Declares given location and assigns it given data type.
		///
		/// Since registers cannot be assigned a type, this method does nothing if `location` represents a register.
		public mutating func declare(_ location: Location, type newType: DataType) throws {
			
			if case .register = location { return }
			
			let previousType = typesByLocation.updateValue(newType, forKey: location)
			if let previousType = previousType, previousType != newType {
				throw TypeError.inconsistentTyping(location, previousType, newType)
			}
			
		}
		
		/// Requires given location to be declared and typed `requiredType`.
		public func require(_ location: Location, type requiredType: DataType) throws {
			if let previousType = typesByLocation[location], previousType != requiredType {
				throw TypeError.inconsistentTyping(location, previousType, requiredType)
			}
		}
		
		/// Requires given source to be typed `requiredType`, and if it represents a location, that location to be declared.
		public func require(_ source: Source, type requiredType: DataType) throws {
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
		
		/// Removes given location.
		public mutating func remove(_ location: Location) {
			typesByLocation.removeValue(forKey: location)
		}
		
		enum TypeError : LocalizedError {
			
			/// An error indicating that the value type of given location cannot be determined.
			case unknownType(Location)
			
			/// An error indicating that given constant cannot be represented by a value of given type.
			case constantNotRepresentableByType(Int, DataType)
			
			/// An error indicating that given location is bound to different value types.
			case inconsistentTyping(Location, DataType, DataType)
			
			/// An error indicating that given typed locations have different value types when they should have the same value type.
			case unequalTypes(TypedLocation, TypedLocation)
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					
					case .unknownType(let location):
					return "No known type for “\(location)”"
					
					case .constantNotRepresentableByType(let value, let type):
					return "\(value) cannot be represented by a value typed \(type)"
					
					case .inconsistentTyping(let location, let firstType, let otherType):
					return "“\(location)” is simultaneously typed \(firstType) and \(otherType)"
					
					case .unequalTypes(let first, let second):
					return "\(first) does not have the same type as \(second)"
					
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
			typesByLocation
				.map { $0.key ~ $0.value }
				.sorted()	// ensure deterministic ordering by sorting
		)
	}
	
}
