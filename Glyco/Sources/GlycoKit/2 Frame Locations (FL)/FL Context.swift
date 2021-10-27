// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	/// A value encompassing information required across program elements.
	///
	/// One context should be created for every program; contexts should not be reused across programs.
	public struct Context {
		
		/// Creates a context for a new program.
		public init() {}
		
		/// The number of bytes that have been allocated.
		private(set) var allocatedBytes: Int = 0
		
		/// Allocates space for a datum of type `type` and returns the datum's offset relative to the frame pointer.
		mutating func allocate(_ type: DataType) -> Int {
			allocatedBytes += type.byteSize
			return -allocatedBytes
		}
		
	}
	
}
