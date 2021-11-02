// Glyco © 2021 Constantino Tsarouhas

extension CD {
	
	/// A value used during lowering.
	struct Context {
		
		/// Allocates a label for a new block.
		mutating func allocateBlockLabel() -> Lower.Label {
			defer { allocatedBlocks += 1 }
			return .init(rawValue: "BB\(allocatedBlocks)")
		}
		
		/// The number of allocated blocks.
		private var allocatedBlocks = 0
		
	}
	
}
