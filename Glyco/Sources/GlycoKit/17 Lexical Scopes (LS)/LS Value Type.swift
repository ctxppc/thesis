// Glyco © 2021–2022 Constantino Tsarouhas

extension LS {
	
	/// A value denoting the type of a value.
	public enum ValueType : Equatable, Codable, SimplyLowerable {
		
		/// An unsigned byte or 1-byte integer.
		case u8
		
		/// A signed 4-byte integer.
		case s32
		
		/// A capability of given type.
		case cap(CapabilityType)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.ValueType {
			switch self {
				case .u8:			return .u8
				case .s32:			return .s32
				case .cap(let t):	return .cap(try t.lowered(in: &context))
			}
		}
		
	}
	
}