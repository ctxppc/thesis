// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension ALA {
	
	/// A location with an associated value type.
	public enum TypedLocation : Equatable, Codable {
		
		/// An abstract location, to be lowered to a physical location after register allocation.
		case abstract(AbstractLocation, ValueType)
		
		/// A location fixed to given frame location.
		case frame(Frame.Location, ValueType)
		
		/// The location.
		var location: Location {
			switch self {
				case .abstract(let location, _):	return .abstract(location)
				case .frame(let location, _):		return .frame(location)
			}
		}
		
		/// The location's value type.
		var valueType: ValueType {
			switch self {
				case .abstract(_, let dataType),
					.frame(_, let dataType):
				return dataType
			}
		}
		
	}
	
}

infix operator ~ : ComparisonPrecedence

public func ~ (location: ALA.Location, type: ALA.ValueType) -> ALA.TypedLocation {
	switch location {
		case .abstract(let location):	return .abstract(location, type)
		case .frame(let location):		return .frame(location, type)
		case .register:					fatalError("Cannot associate a type with a register")
	}
}
