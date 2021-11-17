// Glyco © 2021 Constantino Tsarouhas

extension PR {
	
	/// A value that can be used in a conditional.
	public enum Predicate : Codable, Equatable {
		
		/// A constant predicate.
		case constant(Bool)
		
		/// A predicate that is the negation of a given predicate.
		indirect case not(Predicate)
		
		/// A predicate that holds iff *x* `relation` *y*, where *x* is the value of `lhs` and *y* is the value of `rhs`.
		case relation(lhs: Source, relation: BranchRelation, rhs: Source)
		
	}
	
}
