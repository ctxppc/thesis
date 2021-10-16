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
		
		/// Returns a set of locations (potentially) accessed by `self`.
		public func accessedLocations() -> Set<Location> {
			result.accessedLocations()
		}
		
		/// Returns a representation of `self` in a lower language.
		///
		/// - Parameter homes: A dictionary mapping abstract locations to physical locations.
		///
		/// - Returns: A representation of `self` in a lower language.
		public func lowered(homes: [Location : Lower.Location]) -> Lower.HaltEffect {
			.init(result: result.lowered(homes: homes))
		}
		
	}
	
}
