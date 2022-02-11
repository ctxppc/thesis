// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// A value denoting the type of a value.
	public enum ValueType : Equatable, Codable, SimplyLowerable {
		
		/// An unsigned byte or 1-byte integer.
		case byte
		
		/// A signed 4-byte integer.
		case signedWord
		
		/// A capability to elements of given type.
		indirect case capability(ValueType)
		
		/// A datum with unspecified interpretation that fits in a register.
		case registerDatum
		
		/// The size of a datum of this type, in bytes.
		public var byteSize: Int {
			lowered().byteSize
		}
		
		func lowered() -> Lower.DataType {
			switch self {
				case .byte:				return .byte
				case .signedWord:		return .signedWord
				case .capability:		return .capability
				case .registerDatum:	return .capability
			}
		}
		
		// See protocol.
		func lowered(in context: inout ()) -> Lower.DataType {
			lowered()
		}
		
	}
	
}
