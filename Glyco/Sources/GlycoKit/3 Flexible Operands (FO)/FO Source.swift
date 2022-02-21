// Glyco © 2021–2022 Constantino Tsarouhas

extension FO {
	
	/// A datum source.
	public enum Source : Codable, Equatable {
		
		/// Creates a source with given location.
		init(_ location: Location) {
			switch location {
				case .register(let register):	self = .register(register)
				case .frame(let location):	self = .frame(location)
			}
		}
		
		/// The operand is given value.
		case immediate(Int)
		
		/// The operand is a value in given register.
		case register(Register)
		
		/// The operand is a value in given frame location.
		case frame(Frame.Location)
		
		/// The location the operand is retrieved from, or `nil` if the operand is not retrieved from a location.
		var location: Location? {
			switch self {
				case .immediate:				return nil
				case .register(let register):	return .register(register)
				case .frame(let location):		return .frame(location)
			}
		}
		
	}
	
}
