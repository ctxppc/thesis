// Glyco © 2021–2022 Constantino Tsarouhas

extension CC {
	
	/// A value denoting the type of a value.
	public enum ValueType : SimplyLowerable, Element {
		
		/// An unsigned byte or 1-byte integer.
		case u8
		
		/// A signed 4-byte integer.
		case s32
		
		/// A capability of given type.
		case cap(CapabilityType)
		
		// See protocol.
		func lowered(in context: inout Context) -> Lower.ValueType {
			lowered()
		}
		
		/// Returns a representation of `self` in the lower language.
		func lowered() -> Lower.ValueType {
			switch self {
				case .u8:			return .u8
				case .s32:			return .s32
				case .cap(let t):	return .cap(t.lowered())
			}
		}
		
	}
	
}
