// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension CV {
	
	/// An effect on a CV machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs given effects.
		case `do`([Effect])
		
		/// An effect that evaluates given value and puts it in given location.
		case set(Location, to: Value)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(of: Location, at: Source, to: Source)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect)
		
		/// An effect that invokes the labelled procedure passing given arguments.
		case call(Label, [Source])
		
		/// An effect that terminates the program with `result`.
		case `return`(Source)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects):
				return .do(try effects.lowered(in: &context))
				
				case .set(let destination, to: .source(let source)):
				return .set(destination, to: .source(source))
					
				case .set(let destination, to: .binary(let lhs, let op, let rhs)):
				return .set(destination, to: .binary(lhs, op, rhs))
				
				case .set(let destination, to: .element(of: let vector, at: let index)):
				return .set(destination, to: .element(of: vector, at: index))
				
				case .set(let destination, to: .vector(let dataType, count: let count)):
				return .set(destination, to: .vector(dataType, count: count))
				
				case .set(let destination, to: .if(let predicate, then: let affirmative, else: let negative)):
				return try .if(
					predicate.lowered(in: &context),
					then: Self.set(destination, to: affirmative).lowered(in: &context),
					else: Self.set(destination, to: negative).lowered(in: &context)
				)
				
				case .set(let destination, to: .do(let effects, then: let source)):
				return try .do(effects.lowered(in: &context) + [Self.set(destination, to: source).lowered(in: &context)])
				
				case .set(_, to: .call):
				throw LoweringError.intermediateCall
				
				case .setElement(of: let vector, at: let index, to: let element):
				return .setElement(of: vector, at: index, to: element)
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .call(let name, let arguments):
				return .call(name, arguments)
				
				case .return(let result):
				return .return(result)
				
			}
		}
		
		enum LoweringError : LocalizedError {
			case intermediateCall
			var errorDescription: String? {
				switch self {
					case .intermediateCall:	return "Procedure call assignments are currently not supported by Glyco"
				}
			}
		}
		
	}
	
}
