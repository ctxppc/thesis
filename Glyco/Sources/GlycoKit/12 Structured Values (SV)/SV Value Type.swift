// Glyco © 2021–2022 Constantino Tsarouhas

extension SV {
	
	/// A value denoting the type of a value.
	public enum ValueType : Equatable, Codable, SimplyLowerable {
		
		/// An unsigned byte or 1-byte integer.
		case u8
		
		/// A signed 4-byte integer.
		case s32
		
		/// A capability to elements of given type.
		indirect case vectorCap(ValueType)
		
		/// A capability to a record of given type.
		case recordCap(RecordType)
		
		/// A capability to code.
		case codeCap
		
		/// A datum with unspecified interpretation that fits in a register.
		case registerDatum
		
		/// The size of a datum of this type, in bytes.
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
				case .u8:								return .u8
				case .s32:								return .s32
				case .vectorCap, .recordCap, .codeCap:	return .cap
				case .registerDatum:					return .cap
			}
		}
		
	}
	
}
