// Glyco © 2021 Constantino Tsarouhas

extension AL {
	
	/// A value encompassing information required across program elements.
	///
	/// One context should be created for every program; contexts should not be reused across programs.
	public struct Context {
		
		/// Creates a context for a new program.
		public init() {}
		
		/// The number of locations that have been allocated.
		var numberOfAllocatedLocations = 0
		
	}
	
}
