// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension OB {
	
	/// A value denoting the type of a capability.
	public enum CapabilityType : Equatable, Codable, SimplyLowerable {
		
		/// A capability to a vector containing elements of given type.
		///
		/// A vector capability points to the first element of the vector, or to the element of a single-element vector.
		indirect case vector(of: ValueType)
		
		/// A capability to a record of given type.
		case record(RecordType)
		
		/// A (possibly sealed) capability to a function with given parameters and result type.
		///
		/// A function capability may be either unsealed, a sentry capability, or a capability sealed with an object type.
		indirect case function(takes: [Parameter], returns: ValueType)
		
		/// A capability to an object of given type.
		///
		/// An object capability is a sealed capability to an encapsulated value that can only be accessed through methods defined on that object's type. Note that the type of `self` in a method is not an object capability but a capability to the object's state record.
		case object(TypeName)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.CapabilityType {
			switch self {
				
				case .vector(of: let elementType):
				return .vector(of: try elementType.lowered(in: &context), sealed: false)
				
				case .record(let recordType):
				return .record(try recordType.lowered(in: &context), sealed: false)
				
				case .function(takes: let parameters, returns: let resultType):
				return try .function(takes: parameters.lowered(in: &context), returns: resultType.lowered(in: &context))
				
				case .object(let typeName):
				guard let definition = context.type(named: typeName) else { throw LoweringError.unknownObjectType(typeName) }
				guard case .object(_, let objectType) = definition else { throw LoweringError.notAnObjectTypeDefinition(typeName, actual: definition) }
				return .record(try objectType.stateRecordType.lowered(in: &context), sealed: true)
				
			}
		}
		
		enum LoweringError : LocalizedError {
			
			/// An error indicating that no object type is known by given name.
			case unknownObjectType(TypeName)
			
			/// An error indicating the type defined with given name is not an object type.
			case notAnObjectTypeDefinition(TypeName, actual: TypeDefinition)
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					
					case .unknownObjectType(let typeName):
					return "“\(typeName)” is not a known object type"
					
					case .notAnObjectTypeDefinition(let typeName, actual: let actual):
					return "“\(typeName)” is defined as \(actual) and thus not an object type"
					
				}
			}
			
		}
		
	}
	
}
