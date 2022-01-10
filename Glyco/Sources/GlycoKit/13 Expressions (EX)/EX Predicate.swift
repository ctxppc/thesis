// Glyco © 2021–2022 Constantino Tsarouhas

extension EX {
	
	/// A value that can be used in a conditional.
	public enum Predicate : Codable, Equatable, SimplyLowerable {
		
		/// A constant predicate.
		case constant(Bool)
		
		/// A predicate that holds iff *x* *R* *y*, where *x* is the value of the first source, *y* is the value of the second source, and *R* is the branch relation.
		case relation(Value, BranchRelation, Value)
		
		/// A predicate that evaluates to `then` if the predicate holds, or to `else` otherwise.
		indirect case `if`(Predicate, then: Predicate, else: Predicate)
		
		/// A predicate that evaluates to given predicate after associating zero or more values with a name.
		indirect case `let`([Definition], in: Predicate)
		
		/// Lowers `self` to an effect in the lower language.
		///
		/// - Parameters:
		///   - context: The context wherein to lower `self`.
		///   - affirmative: The effect to execute when `self` holds.
		///   - negative: The effect to execute when `self` doesn't hold.
		///
		/// - Returns: An effect in the lower language implementing `self`.
		func lowered(in context: inout Context) throws -> Lower.Predicate {
			switch self {
				
				case .constant(let holds):
				return .constant(holds)
				
				case .relation(let lhs, let relation, let rhs):
				let l = Lower.Symbol(rawValue: "lhs")	// TODO: Risk of shadowing?
				let r = Lower.Symbol(rawValue: "rhs")
				return try .let([
					.init(l, lhs.lowered(in: &context)),
					.init(r, rhs.lowered(in: &context))
				], in: .relation(.symbol(l), relation, .symbol(r)))
				
				case .if(let holds, then: let affirmative, else: let negative):
				return try .if(holds.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .let(let definitions, in: let predicate):
				return try .let(definitions.lowered(in: &context), in: predicate.lowered(in: &context))
				
			}
		}
		
	}
	
}
