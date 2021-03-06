// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension ALA {
	
	/// A location with an associated data type.
	public enum Declaration : Comparable, Element {
		
		/// An abstract location, to be lowered to a physical location after register allocation.
		case abstract(AbstractLocation, DataType)
		
		/// A location fixed to given frame location.
		case frame(Frame.Location, DataType)
		
		/// The declared location.
		var location: Location {
			switch self {
				case .abstract(let location, _):	return .abstract(location)
				case .frame(let location, _):		return .frame(location)
			}
		}
		
		/// The declared location's data type.
		var dataType: DataType {
			switch self {
				case .abstract(_, let dataType),
					.frame(_, let dataType):
				return dataType
			}
		}
		
	}
	
}

infix operator ~ : ComparisonPrecedence

public func ~ (location: ALA.Location, type: ALA.DataType) -> ALA.Declaration {
	switch location {
		case .abstract(let location):	return .abstract(location, type)
		case .frame(let location):		return .frame(location, type)
		case .register:					fatalError("Cannot associate a type with a register")
	}
}
