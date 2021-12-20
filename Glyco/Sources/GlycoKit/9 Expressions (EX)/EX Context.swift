// Glyco © 2021 Constantino Tsarouhas

extension EX {
	
	/// A value used during lowering.
	struct Context {
		
		/// Allocates a location.
		mutating func allocateLocation() -> Lower.Location {
			defer { numberOfAllocatedLocations += 1}
			return .local("_\(numberOfAllocatedLocations)")
		}
		
		/// The number of allocated locations.
		private var numberOfAllocatedLocations = 0
		
	}
	
}
