// Glyco © 2021 Constantino Tsarouhas

extension EX {
	
	/// A value used during lowering.
	struct Context {
		
		/// Allocates a location.
		mutating func allocateLocation() -> Lower.Location {
			defer { allocatedLocationCount += 1}
			return .location(allocatedLocationCount)
		}
		
		/// The number of allocated locations.
		private var allocatedLocationCount = 0
		
	}
	
}
