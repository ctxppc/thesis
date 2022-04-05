// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A value denoting the type of a value.
	public enum ValueType : Equatable, Codable, SimplyLowerable {
		
		/// A named type.
		case named(TypeName)
		
		/// An unsigned byte or 1-byte integer.
		case u8
		
		/// A signed 4-byte integer.
		case s32
		
		/// A capability of given type.
		case cap(CapabilityType)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.ValueType {
			switch self {
				case .named(let name):	return .named(name)
				case .u8:				return .u8
				case .s32:				return .s32
				case .cap(let type):	return .cap(try type.lowered(in: &context))
			}
		}
		
	}
	
}
