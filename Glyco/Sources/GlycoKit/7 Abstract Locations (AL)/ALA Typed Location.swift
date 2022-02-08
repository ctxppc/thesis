// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension ALA {
	
	/// A location with possibly an associated data type.
	public enum TypedLocation : Equatable, Codable {
		
		/// Creates a location associated with given data type.
		///
		/// `dataType` is ignored if `location` is a register location. Registers do not have a fixed type.
		init(location: Location, dataType: DataType?) {
			switch location {
				case .abstract(let location):	self = .abstract(location, dataType)
				case .register(let register):	self = .register(register)
				case .frame(let location):		self = .frame(location, dataType)
			}
		}
		
		/// An abstract location, to be lowered to a physical location after register allocation.
		case abstract(AbstractLocation, DataType?)
		
		/// A location fixed to given register.
		case register(Register)
		
		/// A location fixed to given frame location.
		case frame(Frame.Location, DataType?)
		
		/// The location.
		var location: Location {
			switch self {
				case .abstract(let location, _):	return .abstract(location)
				case .register(let register):		return .register(register)
				case .frame(let location, _):		return .frame(location)
			}
		}
		
		/// The location's data type, if fixed.
		var dataType: DataType? {
			switch self {
				
				case .abstract(_, let dataType), .frame(_, let dataType):
				return dataType
				
				case .register:
				return nil
				
			}
		}
		
	}
	
}
