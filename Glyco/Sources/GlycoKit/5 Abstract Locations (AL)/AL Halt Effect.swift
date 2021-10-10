// Glyco © 2021 Constantino Tsarouhas

/// An AL effect where the machine halts execution of the program.
struct ALHaltEffect : Codable {
	
	/// The source of the result value.
	var result: ALSource
	
}

extension ALHaltEffect {
	
	/// Returns a set of locations (potentially) accessed by `self`.
	func accessedLocations() -> Set<ALLocation> {
		result.accessedLocations()
	}
	
	/// Returns an NE representation of `self`.
	///
	/// - Parameter homes: A dictionary mapping abstract locations to physical locations.
	///
	/// - Returns: An NE representation of `self`.
	func neEffect(homes: [ALLocation : NELocation]) -> NEHaltEffect {
		.init(result: result.neSource(homes: homes))
	}
	
}
