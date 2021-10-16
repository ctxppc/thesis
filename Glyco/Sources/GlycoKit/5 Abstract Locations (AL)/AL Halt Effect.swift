// Glyco © 2021 Constantino Tsarouhas

extension AL {
	
	/// An AL effect where the machine halts execution of the program.
	struct HaltEffect : Codable {
		
		/// The source of the result value.
		var result: Source
		
	}
	
}

extension AL.HaltEffect {
	
	/// Returns a set of locations (potentially) accessed by `self`.
	func accessedLocations() -> Set<AL.Location> {
		result.accessedLocations()
	}
	
	/// Returns an NE representation of `self`.
	///
	/// - Parameter homes: A dictionary mapping abstract locations to physical locations.
	///
	/// - Returns: An NE representation of `self`.
	func neEffect(homes: [AL.Location : NE.Location]) -> NE.HaltEffect {
		.init(result: result.neSource(homes: homes))
	}
	
}
