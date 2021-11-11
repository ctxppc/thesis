// Glyco © 2021 Constantino Tsarouhas

extension AL {
	
	/// A datum source.
	public enum Source : Codable, Equatable {
		
		/// The operand is to be retrieved from a given location.
		case location(Location)
		
		/// The operand is a given value.
		case immediate(Int)
		
		// See protocol.
		func lowered(in context: inout Context) -> Lower.Source {
			switch self {
				case .location(let location):	return .location(location.lowered(in: &context))
				case .immediate(let imm):		return .immediate(imm)
			}
		}
		
		/// Returns the locations that are used by the source.
		func usedLocations() -> Set<Location> {
			switch self {
				case .location(let location):	return [location]
				case .immediate:				return []
			}
		}
		
	}
	
}
