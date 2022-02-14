// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// A value denoting the type of a value.
	public enum ValueType : Equatable, Codable, SimplyLowerable {
		
		/// An unsigned byte or 1-byte integer.
		case byte
		
		/// A signed 4-byte integer.
		case signedWord
		
		/// A capability with a possibly associated element or target value type.
		indirect case capability(ValueType?)
		
		/// A datum with unspecified interpretation that fits in a register.
		case registerDatum
		
		/// The size of a datum of this type, in bytes.
		public var byteSize: Int {
			lowered().byteSize
		}
		
		// See protocol.
		func lowered(in context: inout ()) -> Lower.DataType {
			lowered()
		}
		
		/// Returns a representation of `self` in a lower language.
		func lowered() -> Lower.DataType {
			switch self {
				case .byte:				return .byte
				case .signedWord:		return .signedWord
				case .capability:		return .capability
				case .registerDatum:	return .capability
			}
		}
		
		/// Returns a Boolean value indicating whether a constant with given value can be represented in a value of type `self`.
		///
		/// Register data and capabilities cannot be expressed using constants.
		func supports(constant: Int) -> Bool {
			switch self {
				case .byte:							return UInt8(exactly: constant) != nil
				case .signedWord:					return Int8(exactly: constant) != nil
				case .capability, .registerDatum:	return false
			}
		}
		
	}
	
}
