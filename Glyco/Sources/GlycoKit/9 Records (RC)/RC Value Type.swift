// Glyco © 2021–2022 Constantino Tsarouhas

extension RC {
	
	/// A value denoting the type of a value.
	public enum ValueType : Equatable, Codable, SimplyLowerable {
		
		/// An unsigned byte or 1-byte integer.
		case byte
		
		/// A signed 4-byte integer.
		case signedWord
		
		/// A capability to elements of given type.
		indirect case vectorCapability(ValueType)
		
		/// A capability to a record of given type.
		case recordCapability(RecordType)
		
		/// A datum with unspecified interpretation that fits in a register.
		case registerDatum
		
		/// The size of a datum of this type, in bytes.
		public var byteSize: Int {
			lowered().byteSize
		}
		
		// See protocol.
		func lowered(in context: inout Context) -> Lower.ValueType {
			lowered()
		}
		
		/// Returns a representation of `self` in a lower language.
		func lowered() -> Lower.ValueType {
			switch self {
				
				case .byte:
				return .byte
				
				case .signedWord:
				return .signedWord
				
				case .vectorCapability(let elementType):
				return .capability(elementType.lowered())
					
				case .recordCapability:
				return .capability(nil)
				
				case .registerDatum:
				return .registerDatum
				
			}
		}
		
	}
	
}
