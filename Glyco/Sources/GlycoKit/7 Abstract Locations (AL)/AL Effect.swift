// Glyco © 2021–2022 Constantino Tsarouhas

extension AL {
	
	/// An effect on an AL machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(DataType, Location, to: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
		/// An effect that pushes a vector of `count` elements to the call frame and puts a capability for that vector in `into`.
		case allocateVector(DataType, count: Int = 1, into: Location)
		
		/// An effect that retrieves the element at zero-based position `at` in the vector in `of` and puts it in `to`.
		case getElement(DataType, of: Location, at: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(DataType, of: Location, at: Source, to: Source)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect)
		
		/// An effect that invokes the labelled procedure and uses given locations.
		///
		/// This effect assumes a suitable calling convention has already been applied to the program. The parameter locations are only used for the purposes of liveness analysis.
		case call(Label, [ParameterLocation])
		
		/// An effect that returns to the caller.
		case `return`
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects):
				return .do(try effects.lowered(in: &context), analysisAtEntry: .init())
				
				case .set(let type, let destination, to: let source):
				return .set(type, destination, to: source, analysisAtEntry: .init())
				
				case .compute(let lhs, let operation, let rhs, to: let destination):
				return .compute(lhs, operation, rhs, to: destination, analysisAtEntry: .init())
				
				case .allocateVector(let type, count: let count, into: let vector):
				return .allocateVector(type, count: count, into: vector, analysisAtEntry: .init())
				
				case .getElement(let type, of: let vector, at: let index, to: let destination):
				return .getElement(type, of: vector, at: index, to: destination, analysisAtEntry: .init())
				
				case .setElement(let type, of: let vector, at: let index, to: let element):
				return .setElement(type, of: vector, at: index, to: element, analysisAtEntry: .init())
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(
					predicate.lowered(in: &context),
					then:				affirmative.lowered(in: &context),
					else:				negative.lowered(in: &context),
					analysisAtEntry:	.init()
				)
				
				case .call(let name, let parameters):
				return .call(name, parameters, analysisAtEntry: .init())
				
				case .return:
				return .return(analysisAtEntry: .init())
				
			}
		}
		
	}
	
}
