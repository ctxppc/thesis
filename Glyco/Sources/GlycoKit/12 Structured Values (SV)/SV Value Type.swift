// Glyco © 2021–2022 Constantino Tsarouhas

extension SV {
	
	/// A value denoting the type of a value.
	public enum ValueType : SimplyLowerable, Element {
		
		/// An unsigned byte or 1-byte integer.
		case u8
		
		/// A signed 4-byte integer.
		case s32
		
		/// A capability of given type.
		case cap(CapabilityType)
		
		/// A datum with unspecified interpretation that fits in a register.
		case registerDatum
		
		/// The size of a value of this type, in bytes.
		var byteSize: Int {
			lowered().byteSize
		}
		
		// See protocol.
		func lowered(in context: inout Context) -> Lower.DataType {
			lowered()
		}
		
		/// Returns a representation of `self` in a lower language.
		func lowered() -> Lower.DataType {
			switch self {
				case .u8:					return .u8
				case .s32:					return .s32
				case .cap, .registerDatum:	return .cap
			}
		}
		
	}
	
}
