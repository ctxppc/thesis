// Glyco © 2021 Constantino Tsarouhas

extension AL {
	
	/// A value that can be used in a conditional.
	public enum Predicate : Codable, Equatable, SimplyLowerable {
		
		/// A constant predicate.
		case constant(Bool)
		
		/// A predicate that holds iff *x* *R* *y*, where *x* is the value of the first source, *y* is the value of the second source, and *R* is the branch relation.
		case relation(Source, BranchRelation, Source)
		
		/// A predicate that evaluates to `then` if the predicate holds, or to `else` otherwise.
		indirect case `if`(Predicate, then: Predicate, else: Predicate)
		
		/// Returns a predicate that holds iff `negated` does not hold.
		public static func not(_ negated: Self) -> Self {
			switch negated {
				
				case .constant(value: let holds):
				return .constant(!holds)
				
				case .relation(let lhs, let relation, let rhs):
				return .relation(lhs, relation.negated, rhs)
				
				case .if(let condition, then: let affirmative, else: let negative):
				return .if(condition, then: negative, else: affirmative)
				
			}
		}
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Predicate {
			switch self {
				
				case .constant(value: let holds):
				return .constant(holds)
				
				case .relation(let lhs, let relation, let rhs):
				return try .relation(lhs: lhs.lowered(in: &context), relation: relation, rhs: rhs.lowered(in: &context))
				
				case .if(let condition, then: let affirmative, else: let negative):
				return try .conditional(
					condition:		condition.lowered(in: &context),
					affirmative:	affirmative.lowered(in: &context),
					negative:		negative.lowered(in: &context)
				)
				
			}
		}
		
		/// Returns the locations that are used by the predicate.
		func usedLocations() -> Set<Location> {
			switch self {
				
				case .constant, .relation(.immediate, _, .immediate):
				return []
				
				case .relation(.immediate, _, .location(let location)),
						.relation(.location(let location), _, .immediate):
				return [location]
				
				case .relation(.location(let lhs), _, .location(let rhs)):
				return [lhs, rhs]
				
				case .if(let condition, then: let affirmative, else: let negative):
				return condition.usedLocations().union(affirmative.usedLocations()).union(negative.usedLocations())
				
			}
		}
		
	}
	
	public typealias BranchRelation = Lower.BranchRelation
	
}
