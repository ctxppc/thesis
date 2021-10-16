// Glyco © 2021 Constantino Tsarouhas

extension AL {
	
	/// An AL effect where the machine halts execution of the program.
	public struct HaltEffect : Codable {
		
		/// Creates a halt effect with given result.
		public init(result: Source) {
			self.result = result
		}
		
		/// The source of the result value.
		public var result: Source
		
	}
	
}

extension AL.HaltEffect {
	
	/// Returns a set of locations (potentially) accessed by `self`.
	public func accessedLocations() -> Set<AL.Location> {
		result.accessedLocations()
	}
	
	/// Returns an NE representation of `self`.
	///
	/// - Parameter homes: A dictionary mapping abstract locations to physical locations.
	///
	/// - Returns: An NE representation of `self`.
	public func neEffect(homes: [AL.Location : NE.Location]) -> NE.HaltEffect {
		.init(result: result.neSource(homes: homes))
	}
	
}
