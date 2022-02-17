// Glyco © 2021–2022 Constantino Tsarouhas

extension CF {
	
	/// A value that keeps track of allocated frame cells in a single frame.
	///
	/// A call frame consists of two segments: a caller-managed segment for any provided arguments and a callee-managed segment for allocated frame locations. The first allocated frame location always contains the caller's frame capability.
	public struct Frame {
		
		/// Creates an initial frame, containing no arguments and one allocated location for the caller's frame capability.
		public init() {
			_ = allocate(.cap)	// caller's frame capability
		}
		
		/// The number of bytes assigned to caller-provided arguments.
		///
		/// Arguments are not counted against the allocated byte size of the call frame.
		private(set) var argumentsByteSize = 0
		
		/// Adds a parameter consisting of `count` data of type `type` and returns its location.
		///
		/// This method adds parameters in reverse stack order, i.e., from low to high addresses. Calling conventions which expect parameters in stack order must invoke this method in reverse order.
		public mutating func addParameter(_ type: DataType, count: Int = 1) -> Location {
			argumentsByteSize += type.byteSize * count	// fp[argumentsByteSize] points to last added parameter
			return .init(offset: allocatedByteSize)
		}
		
		/// The number of bytes that have been allocated on the frame.
		private(set) var allocatedByteSize = 0
		
		/// The number of bytes in the memory region spanned by the call frame, including the space taken up by caller-provided arguments.
		var totalByteSize: Int { argumentsByteSize + allocatedByteSize }
		
		/// Allocates space for `count` data of type `type` and returns its location.
		public mutating func allocate(_ type: DataType, count: Int = 1) -> Location {
			defer { allocatedByteSize += type.byteSize * count }	// fp[-allocatedByteSize] points to next free cell
			return .init(offset: -allocatedByteSize)
		}
		
		/// A location to a datum on a frame.
		public struct Location : Codable, Hashable {
			
			/// Creates a location that is located `offset` bytes from the frame base.
			public init(offset: Int) {
				self.offset = offset
			}
			
			/// The location's offset from the frame base, in bytes.
			///
			/// The caller's frame capability is stored at offset 0, allocated frame locations have positive offsets, and frame locations of argument have negative offsets.
			public var offset: Int
			
		}
		
	}
	
}

extension CF.Frame.Location : Comparable {
	public static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.offset < rhs.offset
	}
}
