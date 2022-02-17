// Glyco © 2021–2022 Constantino Tsarouhas

extension CF {
	
	/// A value denoting the type of a datum.
	///
	/// Data types are only introduced in CF because RV doesn't have a uniform interface dealing with arbitrary data types, e.g., there's no single instruction for copying a byte and the load/store instructions differ in format between capabilities and non-capabilities.
	public enum DataType : String, Codable {
		
		/// An unsigned byte or 1-byte integer.
		case u8
		
		/// A signed 4-byte integer.
		case s32
		
		/// An 8-byte capability.
		case cap
		
		/// The size of a datum of this type, in bytes.
		public var byteSize: Int {
			switch self {
				case .u8:			return 1
				case .s32:			return 4
				case .cap:	return 8
			}
		}
		
		/// Returns a Boolean value indicating whether a constant with given value can be represented in a datum of type `self`.
		///
		/// Capabilities cannot be expressed using constants.
		func supports(constant: Int) -> Bool {
			switch self {
				case .u8:			return UInt8(exactly: constant) != nil
				case .s32:			return Int8(exactly: constant) != nil
				case .cap:	return false
			}
		}
		
	}
	
}

extension CF.DataType : Comparable {
	public static func < (firstType: Self, laterType: Self) -> Bool {
		firstType.rawValue < laterType.rawValue
	}
}
