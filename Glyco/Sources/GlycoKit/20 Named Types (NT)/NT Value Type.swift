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
		func lowered(in context: inout LoweringContext) throws -> Lower.ValueType {
			try lowered(in: &context, attemptedResolutions: [])
		}
		
		private func lowered(in context: inout LoweringContext, attemptedResolutions: OrderedSet<TypeName>) throws -> Lower.ValueType {
			switch self {
				
				case .named(let name):
				guard !attemptedResolutions.contains(name) else { throw TypingError.infiniteType(name, cycle: attemptedResolutions) }
				guard let typeDefinition = context.type(named: name) else { throw TypingError.undefinedType(name) }
				return try typeDefinition.valueType.lowered(in: &context, attemptedResolutions: attemptedResolutions.union([name]))
				
				case .u8:
				return .u8
				
				case .s32:
				return .s32
				
				case .cap(let type):
				return .cap(try type.lowered(in: &context))
				
			}
		}
		
		/// Returns a copy of `self` that does not name a structural type.
		///
		/// The normalised types of two types *A* and *B* are equal iff *A* and *B* are interchangeable.
		func normalised(in context: NTTypeContext, attemptedResolutions: OrderedSet<TypeName> = []) throws -> Self {
			guard case .named(let name) = self else { return self }
			guard !attemptedResolutions.contains(name) else { throw TypingError.infiniteType(name, cycle: attemptedResolutions) }
			guard let typeDefinition = context.type(named: name) else { throw TypingError.undefinedType(name) }
			switch typeDefinition {
				
				case .structural(_, let valueType):
				return try valueType.normalised(in: context, attemptedResolutions: attemptedResolutions.union([name]))
				
				case .nominal:
				return self
				
			}
		}
		
		enum TypingError : LocalizedError {
			
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
