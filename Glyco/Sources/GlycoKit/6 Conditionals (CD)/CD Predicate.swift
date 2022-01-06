// Glyco © 2021–2022 Constantino Tsarouhas

extension CD {
	
	/// A value that can be used in a conditional.
	public enum Predicate : Codable, Equatable {
		
		/// A constant predicate.
		case constant(Bool)
		
		/// A predicate that holds iff *x* *R* *y*, where *R* is the relation, *x* is the value of the first source, and *y* is the value of the second source.
		case relation(Source, BranchRelation, Source)
		
		/// A predicate that evaluates to `then` if the first given predicate holds, or to `else` otherwise.
		indirect case `if`(Predicate, then: Predicate, else: Predicate)
		
		/// Returns a copy of `self` that may be more optimised.
		func optimised() -> Self {
			switch self {
				
				case .constant:
				return self
				
				case .relation(.immediate(let lhs), let relation, .immediate(let rhs)):
				return .constant(relation.holds(lhs, rhs))
				
				case .relation(let lhs, let relation, let rhs) where lhs == rhs:
				return .constant(relation.reflexive)
				
				case .if(.constant(true), then: let affirmative, else: _):
				return affirmative.optimised()
				
				case .if(.constant(false), then: _, else: let negative):
				return negative.optimised()
				
				case .if(let condition, then: let affirmative, else: let negative):
				let newCondition = condition.optimised()
				if condition != newCondition {
					return .if(newCondition, then: affirmative.optimised(), else: negative.optimised()).optimised()
				} else {
					return .if(condition, then: affirmative.optimised(), else: negative.optimised())
				}
				
				default:
				return self
				
			}
		}
		
		/// Returns a representation of `self` in a lower language.
		///
		/// - Parameters:
		///    - context: The context in which `self` is being lowered.
		///    - entryLabel: The label of the entry block representing `self`.
		///    - previousEffects: Effects to be executed in the entry block before evaluating the predicate.
		///    - affirmativeTarget: The label of the block to jump to if `self` holds.
		///    - negativeTarget: The label of the block to jump to if `self` doesn't hold.
		///
		/// - Returns: A representation of `self` in a lower language.
		func lowered(
			in context:			inout Context,
			entryLabel:			Lower.Label,
			previousEffects:	[Lower.Effect],
			affirmativeTarget:	Lower.Label,
			negativeTarget:		Lower.Label
		) -> [Lower.Block] {
			switch self {
				
				case .constant(let holds):
				return [.intermediate(entryLabel, previousEffects, then: holds ? affirmativeTarget : negativeTarget)]
				
				case .relation(let lhs, let relation, let rhs):
				return [.branch(entryLabel, previousEffects, if: .relation(lhs, relation, rhs), then: affirmativeTarget, else: negativeTarget)]
				
				case .if(let condition, then: let affirmative, else: let negative):
				let intermediateAffirmative = context.allocateBlockLabel()
				let intermediateNegative = context.allocateBlockLabel()
				let conditionBlocks = condition.lowered(
					in:					&context,
					entryLabel:			entryLabel,
					previousEffects:	previousEffects,
					affirmativeTarget:	intermediateAffirmative,
					negativeTarget:		intermediateNegative
				)
				let affirmativeBlocks = affirmative.lowered(
					in:					&context,
					entryLabel:			intermediateAffirmative,
					previousEffects:	[],
					affirmativeTarget:	affirmativeTarget,
					negativeTarget:		negativeTarget
				)
				let negativeBlocks = negative.lowered(
					in:					&context,
					entryLabel:			intermediateNegative,
					previousEffects:	[],
					affirmativeTarget:	affirmativeTarget,
					negativeTarget:		negativeTarget
				)
				return conditionBlocks + affirmativeBlocks + negativeBlocks
				
			}
		}
		
	}
	
}
