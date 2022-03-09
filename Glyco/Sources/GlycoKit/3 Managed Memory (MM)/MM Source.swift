// Glyco © 2021–2022 Constantino Tsarouhas

extension MM {
	
	/// A datum source.
	public enum Source : Codable, Equatable, SimplyLowerable {
		
		/// The operand is given value.
		case constant(Int)
		
		/// The operand is a value in given register.
		case register(Register)
		
		// See protocol.
		func lowered(in context: inout ()) throws -> Lower.Source {
			switch self {
				case .constant(let value):		return .constant(value)
				case .register(let register):	return .register(try register.lowered())
			}
		}
		
	}
	
}
