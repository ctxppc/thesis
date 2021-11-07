// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	/// A value that keeps track of allocated frame cells in a single frame.
	public struct Frame {
		
		/// Creates an empty frame.
		public init() {}
		
		/// The number of bytes that have been allocated on the frame.
		private(set) var allocatedBytes = 0
		
		/// Allocates space for a datum of type `type` and returns its location.
		public mutating func allocate(_ type: DataType) -> Location {
			allocatedBytes += type.byteSize
			return .init(offset: -allocatedBytes)
		}
		
		/// A location to a datum on a frame.
		public struct Location : Codable {
			
			/// Creates a location with given offset (in bytes) from the frame pointer.
			fileprivate init(offset: Int) {
				self.offset = offset
			}
			
			/// The location's offset from the frame pointer, in bytes.
			let offset: Int
			
		}
		
	}
	
}