// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation
import OrderedCollections

extension NT {
	
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
			try lowered(in: &context, attemptedResolutions: [])
		}
		
		private func lowered(in context: inout Context, attemptedResolutions: OrderedSet<TypeName>) throws -> Lower.ValueType {
			switch self {
				
				case .named(let name):
				guard !attemptedResolutions.contains(name) else { throw LoweringError.infiniteType(name, cycle: attemptedResolutions) }
				guard let type = context.valueTypesByName[name]?.last else { throw LoweringError.undefinedType(name) }
				return try type.lowered(in: &context, attemptedResolutions: attemptedResolutions.union([name]))
				
				case .u8:
				return .u8
				
				case .s32:
				return .s32
				
				case .cap(let type):
				return .cap(try type.lowered(in: &context))
				
			}
		}
		
		enum LoweringError : LocalizedError {
			
			/// An error indicating that no type is defined with given name.
			case undefinedType(TypeName)
			
			/// An error indicating that given type is defined as itself.
			case infiniteType(TypeName, cycle: OrderedSet<TypeName>)
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					
					case .undefinedType(let name):
					return "“\(name)” is not a defined type"
					
					case .infiniteType(let name, cycle: let cycle):
					return "“\(name)” is defined as \(cycle.map { "\($0)" }.joined(separator: " which is defined as ")), and thus an infinite type"
					
				}
			}
			
		}
		
	}
	
}
