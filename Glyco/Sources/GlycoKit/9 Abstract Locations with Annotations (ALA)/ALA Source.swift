// Glyco © 2021–2022 Constantino Tsarouhas

import Sisp

extension ALA {
	
	/// A datum source.
	public enum Source : PartiallyStringCodable, PartiallyIntCodable, SimplyLowerable, Element {
		
		/// The operand is given value.
		case constant(Int)
		
		/// The operand is to be retrieved from given abstract location.
		case abstract(AbstractLocation)
		
		/// The operand is to be retrieved from given register, typed with given data type.
		case register(Register, DataType)
		
		/// The operand is to be retrieved from given frame location.
		case frame(Frame.Location)
		
		/// The operand is a capability to a memory location with given label.
		case capability(to: Label)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Source {
			switch self {
				case .constant(let imm):			return .constant(imm)
				case .abstract(let location):		return .init(try location.lowered(in: &context))
				case .register(let register, _):	return .register(register)
				case .frame(let location):			return .frame(location)
				case .capability(to: let label):	return .capability(to: label)
			}
		}
		
		/// The location the operand is retrieved from, or `nil` if the operand is not retrieved from a location.
		var location: Location? {
			switch self {
				case .constant, .capability:		return nil
				case .abstract(let location):		return .abstract(location)
				case .register(let register, _):	return .register(register)
				case .frame(let location):			return .frame(location)
			}
		}
		
	}
	
}
