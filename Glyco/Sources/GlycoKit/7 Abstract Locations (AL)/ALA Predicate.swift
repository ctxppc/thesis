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
		
		/// Returns a copy of `self` with updated analysis at entry.
		///
		/// For each contained effect, the transformation is applied first. If the transformed effect contains children, it is applied to those children as well.
		///
		/// - Parameters:
		///    - transform: A function that transforms effects. The default function returns the provided effect unaltered.
		///    - analysis: On method entry, analysis at exit of `self`. On method exit, the analysis at entry of `self`.
		///
		/// - Returns: A copy of `self` where any contained effects have been transformed using `transform` and with updated analysis at entry.
		func updated(using transform: Effect.Transformation = { $0 }, analysis: inout Analysis) throws -> Self {
			try analysis.update(defined: [], possiblyUsed: possiblyUsedLocations())
			switch self {
				
				case .constant(let holds, analysisAtEntry: _):
				return .constant(holds, analysisAtEntry: analysis)
				
				case .relation(let lhs, let relation, let rhs, analysisAtEntry: _):
				return .relation(lhs, relation, rhs, analysisAtEntry: analysis)
				
				case .if(let condition, then: let affirmative, else: let negative, analysisAtEntry: _):
				do {
					
					var analysisAtAffirmativeEntry = analysis
					let updatedAffirmative = try affirmative.updated(using: transform, analysis: &analysisAtAffirmativeEntry)
					
					let updatedNegative = try negative.updated(using: transform, analysis: &analysis)
					analysis.formUnion(with: analysisAtAffirmativeEntry)
					
					let updatedCondition = try condition.updated(using: transform, analysis: &analysis)
					
					return .if(updatedCondition, then: updatedAffirmative, else: updatedNegative, analysisAtEntry: analysis)
					
				}
				
				case .do(let effects, then: let predicate, analysisAtEntry: _):
				return try .do(
					effects
						.reversed()
						.map { try $0.updated(using: transform, analysis: &analysis) }	// update effects in reverse order so that analysis flows backwards
						.reversed(),												// reverse back to normal order
					then: predicate.updated(using: transform, analysis: &analysis),
					analysisAtEntry: analysis
				)
				
			}
		}
		
		/// Returns the locations possibly used by `self`.
		private func possiblyUsedLocations() -> [TypedLocation] {
			switch self {
				
				case .constant,
					.relation(.constant, _, .constant, analysisAtEntry: _),
					.if,
					.do:
				return []
				
				case .relation(.constant, _, .location(let location), analysisAtEntry: _),
					.relation(.location(let location), _, .constant, analysisAtEntry: _):
				return [.init(location: location, dataType: .signedWord)]
				
				case .relation(.location(let lhs), _, .location(let rhs), analysisAtEntry: _):
				return [
					.init(location: lhs, dataType: .signedWord),
					.init(location: rhs, dataType: .signedWord)
				]
				
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
					.first
					?? predicate.safelyCoalescableLocations()
				
			}
		}
		
		/// Returns a copy of `self` where `removedLocation` is coalesced into `retainedLocation` and the analysis at entry is updated accordingly.
		///
		/// - Parameters:
		///   - removedLocation: The location that is replaced by `retainedLocation`.
		///   - retainedLocation: The location that remains.
		///   - analysis: On method entry, analysis at exit of `self`. On method exit, the analysis at entry of `self`.
		func coalescing(_ removedLocation: AbstractLocation, into retainedLocation: Location, analysis: inout Analysis) throws -> Self {
			try updated(using: { $0.coalescingLocally(removedLocation, into: retainedLocation) }, analysis: &analysis)
		}
		
	}
	
}
