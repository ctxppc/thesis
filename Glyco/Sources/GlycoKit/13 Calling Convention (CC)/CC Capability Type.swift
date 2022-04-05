// Glyco © 2021–2022 Constantino Tsarouhas

extension CC {
	
	/// A value denoting the type of a capability.
	public enum CapabilityType : Equatable, Codable, SimplyLowerable {
		
		/// A (possibly sealed) capability to a vector containing elements of given type.
		///
		/// A vector capability points to the first element of the vector, or to the element of a single-element vector.
		indirect case vector(of: ValueType, sealed: Bool)
		
		/// A (possibly sealed) capability to a value of given type, which is a capability to a single-element vector.
		public static func value(_ type: ValueType, sealed: Bool) -> Self { vector(of: type, sealed: sealed) }
		
		/// A (possibly sealed) capability to a record of given type.
		case record(RecordType, sealed: Bool)
		
		/// A (possibly sealed) capability to a procedure with given parameters and result type.
		///
		/// A procedure capability may be either unsealed, a sentry capability, or a capability sealed with an object type.
		indirect case procedure(takes: [Parameter], returns: ValueType)
		
		/// A (possibly sealed) capability that can be used to seal other capabilities.
		case seal(sealed: Bool)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.CapabilityType {
			lowered()
		}
		
		/// Returns a representation of `self` in the lower language.
		func lowered() -> Lower.CapabilityType {
			switch self {
				
				case .vector(of: let elementType, sealed: let sealed):
				return .vector(of: elementType.lowered(), sealed: sealed)
				
				case .record(let recordType, sealed: let sealed):
				return .record(recordType.lowered(), sealed: sealed)
				
				case .procedure:
				return .code
				
				case .seal(sealed: let sealed):
				return .seal(sealed: sealed)
				
			}
		}
		
	}
	
}
