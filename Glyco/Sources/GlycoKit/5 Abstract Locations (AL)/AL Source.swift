// Glyco © 2021 Constantino Tsarouhas

extension AL {
	
	/// A datum source.
	public enum Source : Codable {
		
		/// The operand is to be retrieved from a given location.
		case location(Location)
		
		/// The operand is a given value.
		case immediate(Int)
		
	}
	
}

extension AL.Source {
	
	/// Returns a set of locations (potentially) accessed by `self`.
	public func accessedLocations() -> Set<AL.Location> {
		switch self {
			case .location(let location):	return [location]
			case .immediate:				return []
		}
	}
	
	/// Returns an NE representation of `self`.
	///
	/// - Parameter homes: A dictionary mapping abstract locations to physical locations.
	///
	/// - Returns: An NE representation of `self`.
	public func neSource(homes: [AL.Location : NE.Location]) -> NE.Source {
		switch self {
			case .location(let location):	return .location(location.neLocation(homes: homes))
			case .immediate(let imm):		return .immediate(imm)
		}
	}
	
}
