// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation
import OrderedCollections
import Sisp

extension NT {
	
	/// A value denoting the type of a value.
	public enum ValueType : PartiallyStringCodable, Equatable, SimplyLowerable {
		
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
			switch try structural(in: context) {
				case .named:			fatalError("Unexpected named typed in structural type")
				case .u8:				return .u8
				case .s32:				return .s32
				case .cap(let type):	return .cap(try type.lowered(in: &context))
			}
		}
		
		/// Returns a copy of `self` that does not name a structural type.
		///
		/// The normalised types of two types *A* and *B* are equal iff *A* and *B* are interchangeable.
		func normalised(in context: NTTypeContext, attemptedResolutions: OrderedSet<TypeName> = []) throws -> Self {
			switch self {
				
				case .named(let name):
				guard !attemptedResolutions.contains(name) else { throw TypingError.infiniteType(name, cycle: attemptedResolutions) }
				guard let typeDefinition = context.type(named: name) else { throw TypingError.undefinedType(name) }
				switch typeDefinition {
					
					case .structural(_, let valueType):
					return try valueType.normalised(in: context, attemptedResolutions: attemptedResolutions.union([name]))
					
					case .nominal:
					return self
					
				}
				
				case .u8, .s32, .cap(.seal):
				return self
				
				case .cap(.vector(of: let elementType, sealed: let sealed)):
				return .cap(.vector(
					of:		try elementType.normalised(in: context, attemptedResolutions: attemptedResolutions),
					sealed:	sealed
				))
				
				case .cap(.record(let recordType, sealed: let sealed)):
				return .cap(.record(
					.init(try recordType.fields.map {
						.init($0.name, try $0.valueType.normalised(in: context, attemptedResolutions: attemptedResolutions))
					}),
					sealed: sealed
				))
				
				case .cap(.function(takes: let parameters, returns: let resultType)):
				return .cap(try .function(
					takes:		parameters.map {
						.init(
							$0.name,
							try $0.type.normalised(in: context, attemptedResolutions: attemptedResolutions),
							sealed: $0.sealed
						)
					},
					returns:	resultType.normalised(in: context, attemptedResolutions: attemptedResolutions)
				))
				
			}
		}
		
		/// Returns a copy of `self` that does not name a type.
		func structural(in context: NTTypeContext, attemptedResolutions: OrderedSet<TypeName> = []) throws -> Self {
			switch self {
				
				case .named(let name):
				guard !attemptedResolutions.contains(name) else { throw TypingError.infiniteType(name, cycle: attemptedResolutions) }
				guard let typeDefinition = context.type(named: name) else { throw TypingError.undefinedType(name) }
				return try typeDefinition.valueType.structural(in: context, attemptedResolutions: attemptedResolutions.union([name]))
				
				case .u8, .s32, .cap(.seal):
				return self
				
				case .cap(.vector(of: let elementType, sealed: let sealed)):
				return .cap(.vector(
					of:		try elementType.structural(in: context, attemptedResolutions: attemptedResolutions),
					sealed:	sealed
				))
				
				case .cap(.record(let recordType, sealed: let sealed)):
				return .cap(.record(
					.init(try recordType.fields.map {
						.init($0.name, try $0.valueType.structural(in: context, attemptedResolutions: attemptedResolutions))
					}),
					sealed: sealed
				))
				
				case .cap(.function(takes: let parameters, returns: let resultType)):
				return .cap(try .function(
					takes:		parameters.map {
						.init(
							$0.name,
							try $0.type.structural(in: context, attemptedResolutions: attemptedResolutions),
							sealed: $0.sealed
						)
					},
					returns:	resultType.structural(in: context, attemptedResolutions: attemptedResolutions)
				))
				
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
