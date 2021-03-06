// Glyco © 2021–2022 Constantino Tsarouhas

extension CC {
	
	/// A value denoting the type of a capability.
	public enum CapabilityType : SimplyLowerable, Element {
		
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
		
		/// Returns a copy of `self` but sealed iff `sealed`.
		func sealed(_ sealed: Bool) -> Self {
			switch self {
				case .vector(of: let elementType, sealed: _):	return .vector(of: elementType, sealed: sealed)
				case .record(let recordType, sealed: _):		return .record(recordType, sealed: sealed)
				case .procedure:								return self
				case .seal(sealed: _):							return .seal(sealed: sealed)
			}
		}
		
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
