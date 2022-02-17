// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit

extension CF {
	
	/// A value that keeps track of allocated frame cells in a single frame.
	///
	/// A call frame consists of two segments: a caller-managed segment for any provided arguments and a callee-managed segment for allocated frame locations. The first allocated frame location always contains the caller's frame capability.
	public struct Frame : Codable, Equatable {
		
		/// An initial frame, containing one allocated location for the caller's frame capability.
		public static let initial: Self = with(Self(allocatedByteSize: 0)) {
			_ = $0.allocate(.cap)	// caller's frame capability
		}
		
		/// Creates a frame.
		public init(allocatedByteSize: Int) {
			self.allocatedByteSize = allocatedByteSize
		}
		
		/// The number of bytes that have been allocated on the frame.
		public private(set) var allocatedByteSize: Int
		
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
			/// The caller's frame capability is stored at offset 0, allocated frame locations have positive offsets, and argument frame locations have negative offsets.
			public var offset: Int
			
		}
		
	}
	
}

extension CF.Frame.Location : Comparable {
	public static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.offset < rhs.offset
	}
}
