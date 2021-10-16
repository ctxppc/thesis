// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	/// A location to a frame cell on an FL machine.
	public struct FrameCellLocation : Codable {
		
		/// Allocates a new location, different from every other previously allocated location.
		public static func allocate() -> Self {
			defer { allocations += 1 }
			return Self(offset: -(allocations * stride))
		}
		
		/// The number of locations allocated.
		private static var allocations = 0
		
		/// The stride between locations, in bytes.
		private static let stride = 4
		
		/// Creates a location with given offset (in bytes) from the frame pointer.
		public init(offset: Int) {
			self.offset = offset
		}
		
		/// The location's offset from the frame pointer, in bytes.
		public let offset: Int
		
	}
	
}
