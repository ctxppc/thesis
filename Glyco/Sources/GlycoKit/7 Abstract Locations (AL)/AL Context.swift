// Glyco © 2021 Constantino Tsarouhas

extension AL {
	
	/// A value used during lowering.
	struct Context {
		
		/// Creates a context for a new program.
		init() {}
		
		/// Returns the home for `location`, assigning one if necessary.
		mutating func home(for location: Location) -> Lower.Location {
			homesByLocation[location, default: .frameCell(frame.allocate(.word))]
		}
		
		/// The assigned homes by location in the lower language.
		private var homesByLocation: [Location : Lower.Location] = [:]
		
		/// The frame on which spilled data are stored.
		private var frame = Lower.Frame()
		
	}
	
}
