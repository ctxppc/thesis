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
		func lowered(in context: inout LocalContext) throws -> Lower.Predicate {
			TODO.unimplemented
		}
		
	}
	
}
