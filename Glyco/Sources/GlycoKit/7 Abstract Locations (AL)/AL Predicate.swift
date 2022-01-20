// Glyco © 2021–2022 Constantino Tsarouhas

extension AL {
	
	/// A value that can be used in a conditional.
	public enum Predicate : Codable, Equatable, SimplyLowerable {
		
		/// A constant predicate.
		case constant(Bool)
		
		/// A predicate that holds iff *x* *R* *y*, where *x* is the value of the first source, *y* is the value of the second source, and *R* is the branch relation.
		case relation(Source, BranchRelation, Source)
		
		/// A predicate that evaluates to `then` if the predicate holds, or to `else` otherwise.
		indirect case `if`(Predicate, then: Predicate, else: Predicate)
		
		/// A predicate that performs some effect then evaluates to `then`.
		indirect case `do`([Effect], then: Predicate)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Predicate {
			let analysisAtExit = context.analysis	// the lowered predicate's analysis is the analysis before lowering it
			context.analysis.update(defined: [], possiblyUsed: possiblyUsedLocations())
			switch self {
				
				case .constant(value: let holds):
				return .constant(holds, analysisAtExit)
				
				case .relation(let lhs, let relation, let rhs):
				return .relation(lhs, relation, rhs, analysisAtExit)
				
				case .if(let condition, then: let affirmative, else: let negative):
				do {
					
					let analysisAtEnd = context.analysis	// analysisAtExit == analysisAtEnd as long as if doesn't def/use anything itself but this is cleaner
					
					let loweredAffirmative = try affirmative.lowered(in: &context)
					let analysisAtAffirmativeEntry = context.analysis
					
					context.analysis = analysisAtEnd		// reset for second branch
					let loweredNegative = try negative.lowered(in: &context)
					
					context.analysis.formUnion(with: analysisAtAffirmativeEntry)	// merge analysis of second branch with the one of first branch
					let loweredCondition = try condition.lowered(in: &context)
					
					return .if(loweredCondition, then: loweredAffirmative, else: loweredNegative, analysisAtExit)
					
				}
				
				case .do(let effects, then: let predicate):
				return try .do(
					effects
						.reversed()
						.lowered(in: &context)	// lower the effects in reverse order so that analysis flows backwards
						.reversed(),			// emit effects in the right order by reversing again
					then: predicate.lowered(in: &context),
					analysisAtExit
				)
				
			}
		}
		
		/// Returns the locations possibly used by `self`.
		private func possiblyUsedLocations() -> Set<Location> {
			switch self {

				case .constant,
						.relation(.immediate, _, .immediate),
						.if,
						.do:
				return []

				case .relation(.immediate, _, .location(let location)), .relation(.location(let location), _, .immediate):
				return [location]

				case .relation(.location(let lhs), _, .location(let rhs)):
				return [lhs, rhs]
				
			}
		}
		
	}
	
}
