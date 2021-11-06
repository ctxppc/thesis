// Glyco © 2021 Constantino Tsarouhas

extension AL {
	
	/// A value that can be used in a conditional.
	public enum Predicate : Codable, SimplyLowerable {
		
		/// A constant predicate.
		case constant(Bool)
		
		/// A predicate that holds iff *x* `relation` *y*, where *x* is the value of `lhs` and *y* is the value of `rhs`.
		case relation(lhs: Source, relation: BranchRelation, rhs: Source)
		
		/// A predicate that evaluates to `affirmative` if `condition` holds, or to `negative` otherwise.
		indirect case conditional(condition: Predicate, affirmative: Predicate, negative: Predicate)
		
		/// Returns a predicate that holds iff `negated` does not hold.
		public static func not(_ negated: Self) -> Self {
			switch negated {
				
				case .constant(let holds):
				return .constant(!holds)
				
				case .relation(let lhs, let relation, let rhs):
				return .relation(lhs: lhs, relation: relation.negated, rhs: rhs)
				
				case .conditional(condition: let condition, affirmative: let affirmative, negative: let negative):
				return .conditional(condition: condition, affirmative: negative, negative: affirmative)
				
			}
		}
		
		// See protocol.
		func lowered(in context: inout Context) -> Lower.Predicate {
			switch self {
				
				case .constant(let holds):
				return .constant(holds)
				
				case .relation(lhs: let lhs, relation: let relation, rhs: let rhs):
				return .relation(lhs: lhs.lowered(in: &context), relation: relation, rhs: rhs.lowered(in: &context))
				
				case .conditional(condition: let condition, affirmative: let affirmative, negative: let negative):
				return .conditional(
					condition:		condition.lowered(in: &context),
					affirmative:	affirmative.lowered(in: &context),
					negative:		negative.lowered(in: &context)
				)
				
			}
		}
		
	}
	
	public typealias BranchRelation = Lower.BranchRelation
	
}
