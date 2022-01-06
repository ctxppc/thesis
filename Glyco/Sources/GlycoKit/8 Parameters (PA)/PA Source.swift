// Glyco © 2021–2022 Constantino Tsarouhas

extension PA {
	
	/// A datum source.
	public enum Source : Codable, Equatable, SimplyLowerable {
		
		/// The operand is a given value.
		case immediate(Int)
		
		/// The operand is to be retrieved from a given location.
		case location(Location)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Source {
			switch self {
				case .immediate(let imm):		return .immediate(imm)
				case .location(let location):	return .location(.abstract(location))
			}
		}
		
	}
	
}
