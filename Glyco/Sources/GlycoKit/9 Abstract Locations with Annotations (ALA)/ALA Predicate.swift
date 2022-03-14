// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// A value that can be used in a conditional.
	public enum Predicate : Codable, Equatable, SimplyLowerable {
		
		/// A constant predicate.
		case constant(Bool, analysisAtEntry: Analysis)
		
		/// A predicate that holds iff *x* *R* *y*, where *x* is the value of the first source, *y* is the value of the second source, and *R* is the branch relation.
		case relation(Source, BranchRelation, Source, analysisAtEntry: Analysis)
		
		/// A predicate that evaluates to `then` if the predicate holds, or to `else` otherwise.
		indirect case `if`(Predicate, then: Predicate, else: Predicate, analysisAtEntry: Analysis)
		
		/// A predicate that performs some effect then evaluates to `then`.
		indirect case `do`([Effect], then: Predicate, analysisAtEntry: Analysis)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Predicate {
			switch self {
				
				case .constant(let holds, analysisAtEntry: _):
				return .constant(holds)
				
				case .relation(let lhs, let relation, let rhs, analysisAtEntry: _):
				return try .relation(lhs.lowered(in: &context), relation, rhs.lowered(in: &context))
				
				case .if(let predicate, then: let affirmative, else: let negative, analysisAtEntry: _):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .do(let effects, then: let predicate, analysisAtEntry: _):
				return try .do(effects.lowered(in: &context), then: predicate.lowered(in: &context))
				
			}
		}
		
		/// Returns a transformed copy of `self` with updated analysis at entry.
		///
		/// The transformation is applied first. If the transformed predicate contains predicates or effects, it is applied to those as well.
		///
		/// - Parameters:
		///    - transform: A transformation.
		///    - analysis: On method entry, analysis at exit of `self`. On method exit, the analysis at entry of `self`.
		///    - configuration: The compilation configuration.
		///
		/// - Returns: `transform(self)` with updated analysis at entry.
		func updated(using transform: ALALocalTransformation, analysis: inout Analysis, configuration: CompilationConfiguration) throws -> Self {
			switch try transform(self) {
				
				case .constant(let holds, analysisAtEntry: _):
				return .constant(holds, analysisAtEntry: analysis)
				
				case .relation(let lhs, let relation, let rhs, analysisAtEntry: _):
				try analysis.update(defined: [], possiblyUsed: [lhs, rhs].compactMap(\.location))
				return .relation(lhs, relation, rhs, analysisAtEntry: analysis)
				
				case .if(let condition, then: let affirmative, else: let negative, analysisAtEntry: _):
				do {
					
					var analysisAtAffirmativeEntry = analysis
					let updatedAffirmative = try affirmative.updated(
						using:			transform,
						analysis:		&analysisAtAffirmativeEntry,
						configuration:	configuration
					)
					
					let updatedNegative = try negative.updated(using: transform, analysis: &analysis, configuration: configuration)
					analysis.formUnion(with: analysisAtAffirmativeEntry)
					
					let updatedCondition = try condition.updated(using: transform, analysis: &analysis, configuration: configuration)
					
					return .if(updatedCondition, then: updatedAffirmative, else: updatedNegative, analysisAtEntry: analysis)
					
				}
				
				case .do(let effects, then: let predicate, analysisAtEntry: _):
				// Analysis flows backwards: first update predicate.
				let updatedPredicate = try predicate.updated(using: transform, analysis: &analysis, configuration: configuration)
				// Update subeffects in reverse order so that analysis flows backwards then reverse sequence back to normal order.
				return try .do(
					effects
						.reversed()
						.map { try $0.updated(using: transform, analysis: &analysis, configuration: configuration) }
						.reversed(),
					then: updatedPredicate,
					analysisAtEntry: analysis
				)
				
			}
		}
		
		/// Returns a pair of locations that can be safely coalesced, or `nil` if no such pair is known.
		func safelyCoalescableLocations() -> (AbstractLocation, Location)? {
			switch self {
				
				case .constant, .relation:
				return nil
				
				case .if(let condition, then: let affirmative, else: let negative, analysisAtEntry: _):
				return negative.safelyCoalescableLocations()
					?? affirmative.safelyCoalescableLocations()
					?? condition.safelyCoalescableLocations()
				
				case .do(let effects, then: let predicate, analysisAtEntry: _):
				return effects
					.reversed()
					.lazy
					.compactMap { $0.safelyCoalescableLocations() }
					.first ?? predicate.safelyCoalescableLocations()
				
			}
		}
		
	}
	
}
