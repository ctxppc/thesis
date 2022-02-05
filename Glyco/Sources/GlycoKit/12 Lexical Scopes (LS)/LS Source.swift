// Glyco © 2021–2022 Constantino Tsarouhas

extension LS {
	
	/// A datum source.
	public enum Source : Codable, Equatable, SimplyLowerable {
		
		/// The operand is a given value.
		case constant(Int)
		
		/// The operand is to be retrieved from a given location.
		case symbol(Symbol)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Source {
			switch self {
				case .constant(let value):	return .constant(value)
				case .symbol(let symbol):	return .location(symbol.lowered(in: &context))
			}
		}
		
	}
	
}
