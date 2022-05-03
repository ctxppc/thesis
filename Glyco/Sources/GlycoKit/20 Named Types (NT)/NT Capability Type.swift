// Glyco © 2021–2022 Constantino Tsarouhas

extension NT {
	
	/// A value denoting the type of a capability.
	public enum CapabilityType : Equatable, Codable, SimplyLowerable {
		
		/// A (possibly sealed) capability to a vector containing elements of given type.
		///
		/// A vector capability points to the first element of the vector, or to the element of a single-element vector.
		indirect case vector(of: ValueType, sealed: Bool)
		
		/// A (possibly sealed) capability to a record of given type.
		case record(RecordType, sealed: Bool)
		
		/// A (possibly sealed) capability to a function with given parameters and result type.
		///
		/// A function capability may be either unsealed, a sentry capability, or a capability sealed with an object type.
		indirect case function(takes: [Parameter], returns: ValueType)
		
		/// A (possibly sealed) capability that can be used to seal other capabilities.
		case seal(sealed: Bool)
		
		/// Returns a copy of `self` but sealed iff `sealed`.
		func sealed(_ sealed: Bool) -> Self {
			switch self {
				case .vector(of: let elementType, sealed: _):	return .vector(of: elementType, sealed: sealed)
				case .record(let recordType, sealed: _):		return .record(recordType, sealed: sealed)
				case .function:									return self
				case .seal(sealed: _):							return .seal(sealed: sealed)
			}
		}
		
		// See protocol.
		func lowered(in context: inout LoweringContext) throws -> Lower.CapabilityType {
			switch self {
				
				case .vector(of: let elementType, sealed: let sealed):
				return .vector(of: try elementType.lowered(in: &context), sealed: sealed)
				
				case .record(let recordType, sealed: let sealed):
				return .record(try recordType.lowered(in: &context), sealed: sealed)
				
				case .function(takes: let parameters, returns: let resultType):
				return try .function(takes: parameters.lowered(in: &context), returns: resultType.lowered(in: &context))
				
				case .seal(sealed: let sealed):
				return .seal(sealed: sealed)
				
			}
		}
		
	}
	
}
