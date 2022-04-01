// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	
	/// A value denoting the type of a capability.
	public enum CapabilityType : Equatable, Codable, SimplyLowerable {
		
		/// A capability to a vector containing elements of given type.
		///
		/// A vector capability points to the first element of the vector, or to the element of a single-element vector.
		indirect case vector(of: ValueType)
		
		/// A capability to a value of given type, which is a capability to a single-element vector.
		public static func value(_ type: ValueType) -> Self { vector(of: type) }
		
		/// A capability to a record of given type.
		case record(RecordType)
		
		/// A (possibly sealed) capability to code.
		///
		/// A code capability may be either unsealed, a sentry capability, or a capability sealed with an object type.
		case code
		
		/// A capability to an object.
		///
		/// An object capability is a sealed capability to an encapsulated value that can only be accessed through methods defined on that object's type.
		case object	// TODO: Add type
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.CapabilityType {
			switch self {
				case .vector(of: let elementType):	return .vector(of: try elementType.lowered(in: &context), sealed: false)
				case .record(let recordType):		return .record(recordType, sealed: false)
				case .code:							return .code
				case .object:						TODO.unimplemented
			}
		}
		
	}
	
}
