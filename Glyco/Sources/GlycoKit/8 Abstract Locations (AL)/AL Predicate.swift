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
		
		// See protocol.
		func lowered(in context: inout LocalContext) throws -> Lower.Predicate {
			switch self {
				
				case .constant(value: let holds):
				return .constant(holds)
				
				case .relation(let lhs, let relation, let rhs):
				return try .relation(lhs.lowered(in: &context), relation, rhs.lowered(in: &context))
				
				case .if(let condition, then: let affirmative, else: let negative):
				return try .if(condition.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
			}
		}
		
		/// Returns the locations that are used by the predicate.
		func usedLocations() -> Set<Location> {
			switch self {
				
				case .constant, .relation(.immediate, _, .immediate):
				return []
				
				case .relation(.immediate, _, .location(let location)), .relation(.location(let location), _, .immediate):
				return [location]
				
				case .relation(.location(let lhs), _, .location(let rhs)):
				return [lhs, rhs]
				
				case .if(let condition, then: let affirmative, else: let negative):
				return condition.usedLocations().union(affirmative.usedLocations()).union(negative.usedLocations())
				
			}
		}
		
	}
	
}
