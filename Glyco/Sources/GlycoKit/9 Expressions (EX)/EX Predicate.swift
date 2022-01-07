// Glyco © 2021–2022 Constantino Tsarouhas

extension EX {
	
	/// A value that can be used in a conditional.
	public enum Predicate : Codable, Equatable {
		
		/// A constant predicate.
		case constant(Bool)
		
		/// A predicate that holds iff *x* *R* *y*, where *x* is the value of the first source, *y* is the value of the second source, and *R* is the branch relation.
		case relation(Expression, BranchRelation, Expression)
		
		/// A predicate that evaluates to `then` if the predicate holds, or to `else` otherwise.
		indirect case `if`(Predicate, then: Predicate, else: Predicate)
		
		/// Lowers `self` to an effect in the lower language.
		///
		/// - Parameters:
		///   - context: The context wherein to lower `self`.
		///   - affirmative: The effect to execute when `self` holds.
		///   - negative: The effect to execute when `self` doesn't hold.
		///
		/// - Returns: An effect in the lower language implementing `self`.
		func lowered(in context: inout Context, affirmative: Lower.Effect, negative: Lower.Effect) -> Lower.Effect {
			switch self {
				
				case .constant(let holds):
				return holds ? affirmative : negative
				
				case .relation(.constant(let lhs), let relation, .constant(let rhs)):
				return relation.holds(lhs, rhs) ? affirmative : negative
				
				case .relation(let lhs, let relation, let rhs):
				let lhsValue = context.allocateLocation()
				let rhsValue = context.allocateLocation()
				return .do([
					lhs.lowered(destination: lhsValue, context: &context),
					rhs.lowered(destination: rhsValue, context: &context),
					.if(.relation(.location(lhsValue), relation, .location(rhsValue)), then: affirmative, else: negative),
				])
				
				case .if(let testedPredicate, then: let affirmativePredicate, else: let negativePredicate):
				return testedPredicate.lowered(
					in:				&context,
					affirmative:	affirmativePredicate.lowered(in: &context, affirmative: affirmative, negative: negative),
					negative:		negativePredicate.lowered(in: &context, affirmative: affirmative, negative: negative)
				)
				
			}
		}
		
	}
	
}
