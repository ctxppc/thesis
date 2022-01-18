// Glyco © 2021–2022 Constantino Tsarouhas

extension FL {
	
	/// A value that keeps track of allocated frame cells in a single frame.
	public struct Frame {
		
		/// Creates an empty frame.
		public init() {}
		
		/// The number of bytes that have been allocated on the frame.
		private(set) var allocatedBytes = 0
		
		/// Allocates space for `length` data of type `type` and returns its location.
		public mutating func allocate(_ type: DataType, length: Int = 1) -> Location {
			allocatedBytes += type.byteSize * length
			return .init(offset: -allocatedBytes)
		}
		
		/// A location to a datum on a frame.
		public struct Location : Codable, Hashable {
			
			/// Creates a location that is located `offset` bytes from the frame pointer.
			public init(offset: Int) {
				self.offset = offset
			}
			
			/// The location's offset from the frame pointer, in bytes.
			public var offset: Int
			
		}
		
	}
	
}

extension FL.Frame.Location : Comparable {
	public static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.offset < rhs.offset
	}
}
