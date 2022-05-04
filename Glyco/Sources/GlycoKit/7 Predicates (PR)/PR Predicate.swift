// Glyco © 2021–2022 Constantino Tsarouhas

import Sisp

extension PR {
	
	/// A value that can be used in a conditional.
	public enum Predicate : PartiallyBoolCodable, Equatable {
		
		/// A constant predicate.
		case constant(Bool)
		
		/// A predicate that holds iff *x* `relation` *y*, where *x* is the value of `lhs` and *y* is the value of `rhs`.
		case relation(Source, BranchRelation, Source)
		
	}
	
}
