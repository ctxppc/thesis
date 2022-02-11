// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// A datum source.
	public enum Source : Codable, Equatable, SimplyLowerable {
		
		/// The operand is given value.
		case constant(Int)
		
		/// The operand is to be retrieved from given abstract location.
		case abstract(AbstractLocation)
		
		/// The operand is to be retrieved from given register, typed with given data type.
		case register(Register, ValueType)
		
		/// The operand is to be retrieved from given frame location.
		case frame(Frame.Location)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Source {
			switch self {
				case .constant(let imm):			return .immediate(imm)
				case .abstract(let location):		return .location(try location.lowered(in: &context))
				case .register(let register, _):	return .location(.register(register))
				case .frame(let location):			return .location(.frameCell(location))
			}
		}
		
		/// The location the operand is retrieved from, or `nil` if the operand is not retrieved from a location.
		var location: Location? {
			switch self {
				case .constant:						return nil
				case .abstract(let location):		return .abstract(location)
				case .register(let register, _):	return .register(register)
				case .frame(let location):			return .frame(location)
			}
		}
		
	}
	
}
