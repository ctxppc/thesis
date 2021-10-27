// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	/// A location to a frame cell on an FL machine.
	public struct FrameCellLocation : Codable {
		
		/// Allocates a new location, different from every other previously allocated location.
		public static func allocate(_ type: DataType, context: inout Context) -> Self {
			Self(offset: context.allocate(type))
		}
		
		/// Creates a location with given offset (in bytes) from the frame pointer.
		private init(offset: Int) {
			self.offset = offset
		}
		
		/// The location's offset from the frame pointer, in bytes.
		let offset: Int
		
	}
	
}
