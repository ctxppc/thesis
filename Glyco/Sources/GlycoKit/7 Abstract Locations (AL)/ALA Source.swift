// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// A datum source.
	public enum Source : Codable, Equatable, SimplyLowerable {
		
		/// The operand is given value.
		case constant(Int)
		
		/// The operand is to be retrieved from a given location.
		case location(Location)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Source {
			switch self {
				case .constant(let imm):		return .immediate(imm)
				case .location(let location):	return .location(try location.lowered(in: &context))
			}
		}
		
	}
	
}
