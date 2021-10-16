// Glyco © 2021 Constantino Tsarouhas

extension AL {
	
	/// A datum source.
	public enum Source : Codable {
		
		/// The operand is to be retrieved from a given location.
		case location(Location)
		
		/// The operand is a given value.
		case immediate(Int)
		
		/// Returns a set of locations (potentially) accessed by `self`.
		public func accessedLocations() -> Set<Location> {
			switch self {
				case .location(let location):	return [location]
				case .immediate:				return []
			}
		}
		
		/// Returns a representation of `self` in a lower language.
		///
		/// - Parameter homes: A dictionary mapping abstract locations to physical locations.
		///
		/// - Returns: A representation of `self` in a lower language.
		public func lowered(homes: [Location : Lower.Location]) -> Lower.Source {
			switch self {
				case .location(let location):	return .location(location.lowered(homes: homes))
				case .immediate(let imm):		return .immediate(imm)
			}
		}
		
	}
	
}
