// Glyco © 2021 Constantino Tsarouhas

import DepthKit

extension AL {
	
	/// An abstract storage location on an AL machine.
	public struct Location : Codable, Hashable, RawRepresentable, SimplyLowerable {
		
		/// Creates a location.
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
		
		// See protocol.
		public let rawValue: Int
		
		// See protocol.
		func lowered(in context: inout Context) -> Lower.Location {
			context.home(for: self)
		}
		
		/// A value that keeps track of allocated locations.
		public struct Allocator {
			
			/// Creates a fresh allocator.
			public init() {}
			
			/// Allocates space for a datum and returns its location.
			public mutating func allocate() -> Location {
				defer { allocatedLocations += 1 }
				return .init(rawValue: allocatedLocations)
			}
			
			/// The number of bytes that have been allocated on the frame.
			private(set) var allocatedLocations = 0
			
		}
		
	}
	
}

extension AL.Location : CustomStringConvertible {
	public var description: String {
		"\(rawValue)"
	}
}
