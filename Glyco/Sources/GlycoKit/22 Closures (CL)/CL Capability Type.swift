// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension CL {
	
	/// A value denoting the type of a capability.
	public enum CapabilityType : SimplyLowerable, Element {
		
		/// A capability to a vector containing elements of given type.
		///
		/// A vector capability points to the first element of the vector, or to the element of a single-element vector.
		indirect case vector(of: ValueType)
		
		/// A capability to a record of given type.
		case record(RecordType)
		
		/// A (possibly sealed) capability to a function or closure with given parameters and result type.
		indirect case function(takes: [Parameter], returns: ValueType, closure: Bool)
		
		/// A capability to an object of given type.
		///
		/// An object capability is a sealed capability to an encapsulated value that can only be accessed through methods defined on that object's type. Note that the type of `self` in a method is not an object capability but a capability to the object's state record.
		case object(TypeName)
		
		/// A capability that can be used to seal other capabilities.
		case seal
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.CapabilityType {
			switch self {
				
				case .vector(of: let elementType):
				return .vector(of: try elementType.lowered(in: &context))
				
				case .record(let recordType):
				return .record(try recordType.lowered(in: &context))
				
				case .function(takes: let parameters, returns: let resultType, closure: let closure):
				return try (closure ? Lowered.message : Lowered.function)(parameters.lowered(in: &context), resultType.lowered(in: &context))
				
				case .object(let typeName):
				return .object(typeName)
				
				case .seal:
				return .seal
				
			}
		}
		
	}
	
}
