// Glyco © 2021–2022 Constantino Tsarouhas

extension CE {
	
	/// A value denoting the type of a datum.
	public enum DataType : String, Element {
		
		/// An unsigned byte or 1-byte integer.
		case u8
		
		/// A signed 4-byte (32-bit) integer.
		case s32
		
		/// A 16-byte (128-bit) capability.
		case cap
		
		/// The size of a datum of this type, in bytes.
		public var byteSize: Int {
			switch self {
				case .u8:	return 1
				case .s32:	return 4
				case .cap:	return 16
			}
		}
		
		/// Returns a Boolean value indicating whether a constant with given value can be represented in a datum of type `self`.
		///
		/// Capabilities cannot be expressed using constants.
		func supports(constant: Int) -> Bool {
			switch self {
				case .u8:	return UInt8(exactly: constant) != nil
				case .s32:	return Int32(exactly: constant) != nil
				case .cap:	return false
			}
		}
		
	}
	
}

extension CE.DataType : Comparable {
	public static func < (firstType: Self, laterType: Self) -> Bool {
		firstType.rawValue < laterType.rawValue
	}
}
