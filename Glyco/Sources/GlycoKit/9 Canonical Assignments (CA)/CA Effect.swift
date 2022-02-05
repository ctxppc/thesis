// Glyco © 2021–2022 Constantino Tsarouhas

extension CA {
	
	/// An effect on a CA machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
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
				return .set(.word, destination, to: source)
				
				case .set(let destination, to: .binary(let lhs, let op, let rhs)):
				return .compute(lhs, op, rhs, to: destination)
				
				case .set(let destination, to: .element(of: let vector, at: let index)):
				return .getElement(.word, of: vector, at: index, to: destination)
				
				case .set(let destination, to: .vector(let dataType, count: let count)):
				return .allocateVector(dataType, count: count, into: destination)
				
				case .setElement(of: let vector, at: let index, to: let element):
				return .setElement(.word, of: vector, at: index, to: element)
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .call(let name, let arguments):
				return .call(name, arguments)
				
				case .return(let result):
				return .return(.word, result)
				
			}
		}
		
	}
	
}
