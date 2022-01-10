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
		func lowered(in context: inout LocalContext) throws -> Lower.Predicate {
			switch self {
				
				case .constant(value: let holds):
				return .constant(holds)
				
				case .relation(let lhs, let relation, let rhs):
				return try .relation(lhs.lowered(in: &context), relation, rhs.lowered(in: &context))
				
				case .if(let condition, then: let affirmative, else: let negative):
				return try .if(condition.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))

				case .do(let effects, then: let predicate):
				return try .do(effects.lowered(in: &context), then: predicate.lowered(in: &context))
				
			}
		}
		
		/// Returns a tuple consisting of (1) a set partitioning locations whose current value is either possibly used or definitely not used at the point *right before* executing `self` and (2) an undirected graph of locations who are connected iff they simultaneously hold a value that is possibly needed by an effect executed in the future.
		///
		/// - Parameter livenessAtExit: The liveness set right after executing `self`.
		/// - Parameter conflictsAtExit: The conflict graph right after executing `self`.
		func livenessAndConflictsAtEntry(livenessAtExit: LivenessSet, conflictsAtExit: ConflictGraph) -> (LivenessSet, ConflictGraph) {
			var livenessAtEntry = livenessAtExit
			var conflictsAtEntry = conflictsAtExit
			switch self {
				
				case .constant, .relation(.immediate, _, .immediate):
				break
				
				case .relation(.immediate, _, .location(let location)), .relation(.location(let location), _, .immediate):
				livenessAtEntry.markAsPossiblyUsedLater([location])
				
				case .relation(.location(let lhs), _, .location(let rhs)):
				livenessAtEntry.markAsPossiblyUsedLater([lhs, rhs])
				
				case .if(let predicate, then: let affirmative, else: let negative):
				let (livenessAtAffirmativeEntry, conflictsAtAffirmativeEntry) =
					affirmative.livenessAndConflictsAtEntry(livenessAtExit: livenessAtExit, conflictsAtExit: conflictsAtExit)
				let (livenessAtNegativeEntry, conflictsAtNegativeEntry) =
					negative.livenessAndConflictsAtEntry(livenessAtExit: livenessAtExit, conflictsAtExit: conflictsAtExit)
				let livenessAtBodyEntry = livenessAtAffirmativeEntry.union(livenessAtNegativeEntry)
				let conflictsAtBodyEntry = conflictsAtAffirmativeEntry.union(conflictsAtNegativeEntry)
				(livenessAtEntry, conflictsAtEntry)
					= predicate.livenessAndConflictsAtEntry(livenessAtExit: livenessAtBodyEntry, conflictsAtExit: conflictsAtBodyEntry)
				
				case .do(let effects, then: let predicate):
				let livenessAndConflictsAtPredicateEntry =
					predicate.livenessAndConflictsAtEntry(livenessAtExit: livenessAtExit, conflictsAtExit: conflictsAtExit)
				(livenessAtEntry, conflictsAtEntry) = effects.reversed().reduce(livenessAndConflictsAtPredicateEntry) {
					$1.livenessAndConflictsAtEntry(livenessAtExit: $0.0, conflictsAtExit: $0.1)
				}
				
			}
			return (livenessAtEntry, conflictsAtEntry)
		}
		
	}
	
}
