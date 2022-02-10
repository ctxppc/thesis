// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension ALA {
	
	/// A data type that can be inferred from context.
	public enum InferrableDataType : Codable, Equatable {
		
		/// Converts given concrete type to an inferrable concrete type.
		init(_ concrete: DataType) {
			switch concrete {
				case .byte:			self = .byte
				case .signedWord:	self = .signedWord
				case .capability:	self = .capability
			}
		}
		
		/// The data type is to be inferred from context.
		case inferred
		
		/// An unsigned byte or 1-byte integer.
		case byte
		
		/// A signed 4-byte integer.
		case signedWord
		
		/// An 8-byte capability.
		case capability
		
		/// Infers a concrete data type.
		///
		/// - Parameters:
		///    - context: The lowering context.
		///    - locations: The locations that are typed `self`.
		///
		/// - Returns: A concrete data type representing `self`.
		func lowered<Locations : Collection>(in context: Context, associatedWith locations: Locations) throws -> Lower.DataType where Locations.Element == Location {
			switch self {
				case .inferred:		return try context.assignments.type(of: locations)
				case .byte:			return .byte
				case .signedWord:	return .signedWord
				case .capability:	return .capability
			}
		}
		
		/// Infers a concrete data type.
		///
		/// - Parameters:
		///    - context: The lowering context.
		///    - locations: The locations that are typed `self`.
		///
		/// - Returns: A concrete data type representing `self`.
		func lowered(in context: Context, associatedWith locations: Location?...) throws -> Lower.DataType {
			try lowered(in: context, associatedWith: locations.compacted())
		}
		
	}
	
}
