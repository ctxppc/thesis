// Glyco © 2021–2022 Constantino Tsarouhas

import Sisp

extension DF {
	
	/// A value that can be used in a conditional.
	public enum Predicate : PartiallyBoolCodable, Equatable, SimplyLowerable {
		
		/// A constant predicate.
		case constant(Bool)
		
		/// A predicate that holds iff *x* *R* *y*, where *x* is the value of the first source, *y* is the value of the second source, and *R* is the branch relation.
		case relation(Source, BranchRelation, Source)
		
		/// A predicate that evaluates to `then` if the predicate holds, or to `else` otherwise.
		indirect case `if`(Predicate, then: Predicate, else: Predicate)
		
		/// A predicate that evaluates to given predicate after associating zero or more values with a name.
		indirect case `let`([Definition], in: Predicate)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Predicate {
			switch self {
				
				case .constant(value: let holds):
				return .constant(holds)
				
				case .relation(let lhs, let relation, let rhs):
				return .relation(lhs, relation, rhs)
				
				case .if(let condition, then: let affirmative, else: let negative):
				return try .if(condition.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .let(let definitions, in: let predicate):
				return try .do(definitions.lowered(in: &context), then: predicate.lowered(in: &context))
				
			}
		}
		
	}
	
}
