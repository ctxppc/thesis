// Glyco © 2021–2022 Constantino Tsarouhas

extension CD {
	
	/// A value that can be used in a conditional.
	public enum Predicate : Codable, Equatable {
		
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
		
		/// Returns a copy of `self` that may be more optimised.
		func optimised() -> Self {
			switch self {
				
				case .constant:
				return self
				
				case .relation(lhs: .immediate(let lhs), relation: let relation, rhs: .immediate(let rhs)):
				return .constant(relation.holds(lhs, rhs))
				
				case .relation(lhs: let lhs, relation: let relation, rhs: let rhs) where lhs == rhs:
				return .constant(relation.reflexive)
				
				case .conditional(condition: .constant(true), affirmative: let affirmative, negative: _):
				return affirmative.optimised()
				
				case .conditional(condition: .constant(false), affirmative: _, negative: let negative):
				return negative.optimised()
				
				case .conditional(condition: let condition, affirmative: let affirmative, negative: let negative):
				let newCondition = condition.optimised()
				if condition != newCondition {
					return .conditional(condition: newCondition, affirmative: affirmative.optimised(), negative: negative.optimised()).optimised()
				} else {
					return .conditional(condition: condition, affirmative: affirmative.optimised(), negative: negative.optimised())
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
				
				case .conditional(condition: let condition, affirmative: let affirmative, negative: let negative):
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
