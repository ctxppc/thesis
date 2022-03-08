// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit

extension CE {
	
	public enum Permission : String, Codable, CaseIterable {
		
		/// The capability can be stored using a capability with either `storeCapability` or `storeLocalCapability` permissions.
		case global
		
		/// The capability can be used for code execution.
		case execute
		
		/// The capability can be used for untagged data loads.
		case load
		
		/// The capability can be used for untagged data stores.
		case store
		
		/// The capability can be used for tagged capability loads if `load` is also allowed.
		case loadCapability
		
		/// The capability can be used for tagged *global* capability stores if `store` is also allowed.
		case storeCapability
		
		/// The capability can be used for tagged capability stores if `store` and `storeCapability` are also allowed.
		case storeLocalCapability
		
		/// The capability can be used to seal a capability using the former capability's address as the latter capability's object type.
		case seal
		
		/// The capability can be used in an invocation, as a code capability if `execute` is allowed or as a data capability if `execute` is denied.
		case invoke
		
		/// The capability can be used to unseal a capability whose object type is equal to the former capability's address.
		case unseal
		
		/// The capability can be used
		case setCID
		
		/// The permission's bitmask index.
		public var bitmaskIndex: Int { Self.indicesByPermission[self] !! "Expected permission" }
		
		private static let indicesByPermission = [Self : Int](
			uniqueKeysWithValues: allCases.enumerated().map { ($0.element, $0.offset) }
		)
		
	}
	
}

extension Sequence where Element == CE.Permission {
	
	/// A bitmask representing the permissions in `self`.
	var bitmask: UInt {
		self.lazy
			.map { UInt($0.bitmaskIndex) }
			.reduce(0, |)
	}
	
}
