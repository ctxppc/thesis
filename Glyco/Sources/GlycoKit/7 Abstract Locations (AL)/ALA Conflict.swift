// Glyco © 2021–2022 Constantino Tsarouhas

import Algorithms
import DepthKit

extension ALA {
	
	public struct Conflict : Hashable, Codable {
		
		/// Creates a conflict between two given locations.
		public init(_ first: Location, _ second: Location) {
			self.first = first
			self.second = second
		}
		
		/// The first location in the conflict.
		public let first: Location
		
		/// The second location in the conflict.
		public let second: Location
		
	}
	
}

extension ALA.Conflict : Comparable {
	public static func < (firstConflict: Self, laterConflict: Self) -> Bool {
		(firstConflict.first, firstConflict.second) < (laterConflict.first, laterConflict.second)
	}
}
