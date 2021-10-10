// Glyco © 2021 Constantino Tsarouhas

/// A datum source.
enum ALSource : Codable {
	
	/// The operand is to be retrieved from a given location.
	case location(ALLocation)
	
	/// The operand is a given value.
	case immediate(Int)
	
}

extension ALSource {
	
	/// Returns a set of locations (potentially) accessed by `self`.
	func accessedLocations() -> Set<ALLocation> {
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
	func neSource(homes: [ALLocation : NELocation]) -> NESource {
		switch self {
			case .location(let location):	return .location(location.neLocation(homes: homes))
			case .immediate(let imm):		return .immediate(imm)
		}
	}
	
}
