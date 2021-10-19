// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	/// A location to a frame cell on an FL machine.
	public struct FrameCellLocation : Codable {
		
		/// Allocates a new location, different from every other previously allocated location.
		public static func allocate(context: inout Context) -> Self {
			defer { context.numberOfAllocatedLocations += 1 }
			return Self(offset: -(context.numberOfAllocatedLocations * stride))
		}
		
		/// The stride between locations, in bytes.
		private static let stride = 4
		
		/// Creates a location with given offset (in bytes) from the frame pointer.
		init(offset: Int) {
			self.offset = offset
		}
		
		/// The location's offset from the frame pointer, in bytes.
		let offset: Int
		
	}
	
}
