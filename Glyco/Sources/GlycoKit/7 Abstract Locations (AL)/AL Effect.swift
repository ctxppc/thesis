// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit

extension AL {
	
	/// An effect on an AL machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(DataType, Location, to: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
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
		
		/// An effect that terminates the program with `result`.
		case `return`(DataType, Source)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Effect {
			let analysisAtExit = context.analysis	// the lowered effect's analysis is the analysis before lowering it
			context.analysis.update(defined: definedLocations(), possiblyUsed: possiblyUsedLocations())
			switch self {
				
				case .do(let effects):
				return .do(
					try effects
						.reversed()
						.lowered(in: &context)	// lower the effects in reverse order so that analysis flows backwards
						.reversed(),			// emit effects in the right order by reversing again
					analysisAtExit				// the do effect's analysis is the analysis before lowering its subeffects
				)
				
				case .set(let type, let destination, to: let source):
				return .set(type, destination, to: source, analysisAtExit)
				
				case .compute(let lhs, let operation, let rhs, to: let destination):
				return .compute(lhs, operation, rhs, to: destination, analysisAtExit)
				
				case .getElement(let type, of: let vector, at: let index, to: let destination):
				return .getElement(type, of: vector, at: index, to: destination, analysisAtExit)
				
				case .setElement(let type, of: let vector, at: let index, to: let element):
				return .setElement(type, of: vector, at: index, to: element, analysisAtExit)
				
				case .if(let predicate, then: let affirmative, else: let negative):
				do {
					
					/*						 │
					┌────────────────────────┼────────────────────────┐
					│    ┌───────────────────▼───────────────────┐    │
					│    │                                       │    │
					│    │               Predicate               │    │
					│    │                                       │    │
					│    └───────┬───────────────────────┬───────┘    │
					│ analysisAtA│firmativeEntry         │            │
					│    ┌───────▼────────┐     ┌────────▼───────┐    │
					│    │  Affirmative   │     │    Negative    │    │
					│    │     branch     │     │     branch     │    │
					│    └───────┬────────┘     └────────┬───────┘    │
					│            │    analysisAtEnd      │            │
					└────────────┼───────────────────────┼────────────┘
								 │    analysisAtExit     │
								 └───────────┬───────────┘
											 │
											 ▼
					 */
					
					let analysisAtEnd = context.analysis	// analysisAtExit == analysisAtEnd as long as if doesn't def/use anything itself but this is cleaner
					
					let loweredAffirmative = try affirmative.lowered(in: &context)
					let analysisAtAffirmativeEntry = context.analysis
					
					context.analysis = analysisAtEnd		// reset for second branch
					let loweredNegative = try negative.lowered(in: &context)
					
					context.analysis.formUnion(with: analysisAtAffirmativeEntry)	// merge analysis of second branch with the one of first branch
					let loweredPredicate = try predicate.lowered(in: &context)
					
					return .if(loweredPredicate, then: loweredAffirmative, else: loweredNegative, analysisAtExit)
					
				}
				
				case .call(let procedure, let parameterLocations):
				return .call(procedure, parameterLocations, analysisAtExit)
				
				case .return(let type, let result):
				return .return(type, result, analysisAtExit)
				
			}
		}
		
		/// Returns the locations defined by `self`.
		private func definedLocations() -> Set<Location> {
			switch self {
				
				case .do, .setElement, .if, .call, .return:
				return []
				
				case .set(_, let destination, to: _),
						.compute(_, _, _, to: let destination),
						.getElement(_, of: _, at: _, to: let destination):
				return [destination]
				
			}
		}
		
		/// Returns the locations possibly used by `self`.
		private func possiblyUsedLocations() -> Set<Location> {
			switch self {
				
				case .do,
						.set(_, _, to: .immediate),
						.compute(.immediate, _, .immediate, to: _),
						.if,
						.return(_, .immediate):
				return []
				
				case .set(_, _, to: .location(let source)),
						.compute(.immediate, _, .location(let source), to: _),
						.compute(.location(let source), _, .immediate, to: _),
						.return(_, .location(let source)):
				return [source]
				
				case .compute(.location(let lhs), _, .location(let rhs), to: _):
				return [lhs, rhs]
				
				case .getElement(_, of: let vector, at: .immediate, to: _),
						.setElement(_, of: let vector, at: .immediate, to: _):
				return [vector]
				
				case .getElement(_, of: let vector, at: .location(let index), to: _),
						.setElement(_, of: let vector, at: .location(let index), to: _):
				return [vector, index]
				
				case .call(_, let arguments):
				return .init(arguments.map { .parameter($0) })
				
			}
		}
		
	}
	
}
