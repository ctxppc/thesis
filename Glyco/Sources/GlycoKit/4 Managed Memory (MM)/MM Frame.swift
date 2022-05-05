// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit

extension MM {
	
	/// A value that keeps track of allocated frame cells in a single frame.
	///
	/// In GCCC, a call frame consists of two segments: a caller-managed segment for any provided arguments and a callee-managed segment for allocated frame locations. The first segment grows in memory order whereas the second segment grows opposite, in stack order. In GHSCC, a call frame only consists of allocated frame locations and grows in memory order.
	///
	/// The first allocated frame location always contains the caller's frame capability. A call frame is capability-aligned, i.e., a frame location with offset 0 points to a location that is appropriately aligned for a capability.
	public struct Frame : Element {
		
		/// Returns an initial frame, containing one allocated location for the caller's frame capability.
		public static func initial(configuration: CompilationConfiguration) -> Self {
			with(Self(allocatedByteSize: 0)) {
				_ = $0.allocate(.cap, configuration: configuration)	// caller's frame capability
			}
		}
		
		/// Creates a frame.
		public init(allocatedByteSize: Int) {
			self.allocatedByteSize = allocatedByteSize
		}
		
		/// The number of bytes that have been allocated on the frame.
		public private(set) var allocatedByteSize: Int
		
		/// Allocates appropriately aligned space for `count` data of type `type` and returns its location.
		public mutating func allocate(_ type: DataType, count: Int = 1, configuration: CompilationConfiguration) -> Location {
			allocatedByteSize = allocatedByteSize.aligned(type)
			defer { allocatedByteSize += type.byteSize * count }	// fp[±allocatedByteSize] points to next free location
			switch configuration.callingConvention {
				case .conventional:	return .init(offset: -allocatedByteSize)
				case .heap:			return .init(offset: allocatedByteSize)
			}
		}
		
		/// A location to a datum on a frame.
		public struct Location : Codable, Hashable {
			
			/// Creates a location that is located `offset` bytes from the frame base.
			public init(offset: Int) {
				self.offset = offset
			}
			
			/// The location's offset from the frame base, in bytes.
			///
			/// The caller's frame capability is stored at offset 0. In GCCC, argument frame locations have positive offsets, and allocated frame locations have negative offsets. In GHSCC, allocated frame locations have positive offsets; there are no argument frame locations.
			public var offset: Int
			
		}
		
	}
	
}

extension MM.Frame.Location : Comparable {
	public static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.offset < rhs.offset
	}
}
