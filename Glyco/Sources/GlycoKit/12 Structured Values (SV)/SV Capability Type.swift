// Glyco © 2021–2022 Constantino Tsarouhas

extension SV {
	
	/// A value denoting the type of a capability.
	public enum CapabilityType : Equatable, Codable {
		
		/// A (possibly sealed) capability to a vector containing elements of given type.
		///
		/// A vector capability points to the first element of the vector, or to the element of a single-element vector.
		indirect case vector(of: ValueType, sealed: Bool)
		
		/// A (possibly sealed) capability to a value of given type, which is a capability to a single-element vector.
		public static func value(_ type: ValueType, sealed: Bool) -> Self { vector(of: type, sealed: sealed) }
		
		/// A (possibly sealed) capability to a record of given type.
		case record(RecordType, sealed: Bool)
		
		/// A (possibly sealed) capability to code.
		///
		/// A code capability may be either unsealed, a sentry capability, or a capability sealed with an object type.
		case code
		
		/// A (possibly sealed) capability that can be used to seal other capabilities.
		case seal(sealed: Bool)
		
	}
	
}
