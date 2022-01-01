// Glyco © 2021–2022 Constantino Tsarouhas

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
			return .location(offset: -allocatedBytes)
		}
		
		/// A location to a datum on a frame.
		public enum Location : Codable, Hashable {
			
			/// A location that is located `offset` bytes from the frame pointer.
			case location(offset: Int)
			
			/// The location's offset from the frame pointer, in bytes.
			var offset: Int {
				switch self {
					case .location(offset: let offset):	return offset
				}
			}
			
		}
		
	}
	
}
