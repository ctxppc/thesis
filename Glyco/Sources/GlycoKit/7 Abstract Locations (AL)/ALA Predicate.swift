// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// A value that can be used in a conditional.
	public enum Predicate : Codable, Equatable, SimplyLowerable {
		
		/// A constant predicate.
		case constant(Bool, Analysis)
		
		/// A predicate that holds iff *x* *R* *y*, where *x* is the value of the first source, *y* is the value of the second source, and *R* is the branch relation.
		case relation(Source, BranchRelation, Source, Analysis)
		
		/// A predicate that evaluates to `then` if the predicate holds, or to `else` otherwise.
		indirect case `if`(Predicate, then: Predicate, else: Predicate, Analysis)
		
		/// A predicate that performs some effect then evaluates to `then`.
		indirect case `do`([Effect], then: Predicate, Analysis)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Predicate {
			switch self {
				
				case .constant(let holds, _):
				return .constant(holds)
				
				case .relation(let lhs, let relation, let rhs, _):
				return try .relation(lhs.lowered(in: &context), relation, rhs.lowered(in: &context))
				
				case .if(let predicate, then: let affirmative, else: let negative, _):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .do(let effects, then: let predicate, _):
				return try .do(effects.lowered(in: &context), then: predicate.lowered(in: &context))
				
			}
		}
		
		/// Updates the analysis at entry of `self`.
		///
		/// - Parameter analysis: On method entry, analysis at exit of `self`. On method exit, the analysis at entry of `self`.
		mutating func update(analysis: inout Analysis) {
			analysis.update(defined: [], possiblyUsed: possiblyUsedLocations())
			switch self {
				
				case .constant(let holds, _):
				self = .constant(holds, analysis)
				
				case .relation(let lhs, let relation, let rhs, _):
				self = .relation(lhs, relation, rhs, analysis)
				
				case .if(var condition, then: var affirmative, else: var negative, _):
				do {
					
					var analysisAtAffirmativeEntry = analysis
					affirmative.update(analysis: &analysisAtAffirmativeEntry)
					
					negative.update(analysis: &analysis)
					analysis.formUnion(with: analysisAtAffirmativeEntry)
					
					condition.update(analysis: &analysis)
					
					self = .if(condition, then: affirmative, else: negative, analysis)
					
				}
				
				case .do(let effects, then: let predicate, _):
				self = .do(
					effects
						.reversed()
						.map { $0.updating(analysis: &analysis) }	// update effects in reverse order so that analysis flows backwards
						.reversed(),								// reverse back to normal order
					then: predicate.updating(analysis: &analysis),
					analysis
				)
				
			}
		}
		
		func updating(analysis: inout Analysis) -> Self {
			var copy = self
			copy.update(analysis: &analysis)
			return copy
		}
		
		/// Returns the locations possibly used by `self`.
		private func possiblyUsedLocations() -> Set<Location> {
			switch self {
				
				case .constant,
					.relation(.immediate, _, .immediate, _),
					.if,
					.do:
				return []
				
				case .relation(.immediate, _, .location(let location), _), .relation(.location(let location), _, .immediate, _):
				return [location]
				
				case .relation(.location(let lhs), _, .location(let rhs), _):
				return [lhs, rhs]
				
			}
		}
		
	}
	
}
