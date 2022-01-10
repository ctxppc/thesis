// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit
import Foundation

extension CA {
	
	/// An effect on a CA machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(Location, to: Value)
		
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
				return .set(destination, to: source)
					
				case .set(let destination, to: .binary(let lhs, let op, let rhs)):
				return .compute(lhs, op, rhs, to: destination)
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(predicate, then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .call(let name, let arguments):
				return .call(name, arguments)
				
				case .return(let result):
				return .return(result)
				
			}
		}
		
	}
	
}
