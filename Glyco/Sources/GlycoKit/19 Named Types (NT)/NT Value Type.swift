// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation
import OrderedCollections

extension NT {
	
	/// A value denoting the type of a value.
	public enum ValueType : Equatable, Codable, SimplyLowerable {
		
		/// A named type.
		case named(Symbol)
		
		/// An unsigned byte or 1-byte integer.
		case u8
		
		/// A signed 4-byte integer.
		case s32
		
		/// A capability to elements of given type.
		indirect case vectorCap(ValueType)
		
		/// A capability to a record of given type.
		case recordCap(RecordType)
		
		/// A capability to code.
		case codeCap
		
		/// A capability that can be used to seal other capabilities.
		case sealCap
		
		/// A datum with unspecified interpretation that fits in a register.
		case registerDatum
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.ValueType {
			try lowered(in: &context, attemptedResolutions: [])
		}
		
		private func lowered(in context: inout Context, attemptedResolutions: OrderedSet<Symbol>) throws -> Lower.ValueType {
			switch self {
				
				case .named(let name):
				guard !attemptedResolutions.contains(name) else { throw LoweringError.infiniteType(name, cycle: attemptedResolutions) }
				guard let type = context.valueTypesByName[name] else { throw LoweringError.undefinedType(name) }
				return try type.lowered(in: &context, attemptedResolutions: attemptedResolutions.union([name]))
				
				case .u8:
				return .u8
				
				case .s32:
				return .s32
				
				case .vectorCap(let valueType):
				return .vectorCap(try valueType.lowered(in: &context))
				
				case .recordCap(let recordType):
				return .recordCap(recordType)
				
				case .codeCap:
				return .codeCap
				
				case .sealCap:
				return .sealCap
				
				case .registerDatum:
				return .registerDatum
				
			}
		}
		
		enum LoweringError : LocalizedError {
			
			/// An error indicating that no type is defined with given name.
			case undefinedType(Symbol)
			
			/// An error indicating that given type is defined as itself.
			case infiniteType(Symbol, cycle: OrderedSet<Symbol>)
			
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
