// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A value denoting the type of a value.
	public enum ValueType : Equatable, Codable, SimplyLowerable {
		
		/// A named type.
		case named(Symbol)
		
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
		
		/// A capability that can be used to seal other capabilities.
		case sealCap
		
		/// An object capability, i.e., a sealed capability to a state value on which methods can be invoked.
		case objectCap
		
		/// A datum with unspecified interpretation that fits in a register.
		case registerDatum
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.ValueType {
			switch self {
				
				case .named(let name):
				return .named(name)
				
				case .u8:
				return .u8
				
				case .s32:
				return .s32
				
				case .vectorCap(let valueType):
				return .vectorCap(try valueType.lowered(in: &context))
				
				case .recordCap(let recordType):
				return .recordCap(recordType)
				
				case .codeCap:
				return .codeCap
				
				case .sealCap:
				return .sealCap
				
				case .objectCap:
				TODO.unimplemented
				
				case .registerDatum:
				return .registerDatum
				
			}
		}
		
	}
	
}
