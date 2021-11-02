// Glyco © 2021 Constantino Tsarouhas

extension CD {
	
	/// A sequence of effects with a single entry and exit point.
	public enum Predicate : Codable {
		
		/// A constant predicate.
		case constant(Bool)
		
		/// A predicate that holds iff *x* `relation` *y*, where *x* is the value of `lhs` and *y* is the value of `rhs`.
		case relation(lhs: Source, relation: BranchRelation, rhs: Source)
		
		/// A predicate that evaluates to `affirmative` if `condition` holds, or to `negative` otherwise.
		indirect case conditional(condition: Predicate, affirmative: Predicate, negative: Predicate)
		
		/// A predicate that performs `effect` then evaluates to `finally`.
		indirect case effectful(effect: Effect, finally: Predicate)
		
		/// Returns a predicate that holds iff `negated` does not hold.
		public static func not(_ negated: Self) -> Self {
			switch negated {
				
				case .constant(let holds):
				return .constant(!holds)
				
				case .relation(let lhs, let relation, let rhs):
				return .relation(lhs: lhs, relation: relation.negated, rhs: rhs)
				
				case .conditional(condition: let condition, affirmative: let affirmative, negative: let negative):
				return .conditional(condition: condition, affirmative: negative, negative: affirmative)
				
				case .effectful(effect: let effect, finally: let finally):
				return .effectful(effect: effect, finally: not(finally))
				
			}
		}
		
		/// Returns a representation of `self` in a lower language.
		///
		/// - Parameters:
		///    - context: The context in which `self` is being lowered.
		///    - entryLabel: The label of the entry block representing `self`.
		///    - affirmativeTarget: The label of the block to jump to if `self` holds.
		///    - negativeTarget: The label of the block to jump to if `self` doesn't hold.
		///    - previousEffects: Effects to be executed in the entry block before evaluating the predicate.
		///
		/// - Returns: A representation of `self` in a lower language.
		func lowered(
			in context:			inout Context,
			entryLabel:			Lower.Label,
			affirmativeTarget:	Lower.Label,
			negativeTarget:		Lower.Label,
			previousEffects:	[Lower.Effect]
		) -> [Lower.Block] {
			switch self {
				
				case .constant(let holds):
				return [
					.intermediate(
						label:		entryLabel,
						effects:	previousEffects,
						successor:	holds ? affirmativeTarget : negativeTarget
					)
				]
				
				case .relation(let lhs, let relation, let rhs):
				return [
					.branch(
						label:			entryLabel,
						effects:		previousEffects,
						predicate:		.relation(lhs: lhs, relation: relation, rhs: rhs),
						affirmative:	affirmativeTarget,
						negative:		negativeTarget
					)
				]
				
				case .conditional(condition: let condition, affirmative: let affirmative, negative: let negative):
				let intermediateAffirmative = context.allocateBlockLabel()
				let intermediateNegative = context.allocateBlockLabel()
				let conditionBlocks = condition.lowered(
					in:					&context,
					entryLabel:			entryLabel,
					affirmativeTarget:	intermediateAffirmative,
					negativeTarget:		intermediateNegative,
					previousEffects:	previousEffects
				)
				let affirmativeBlocks = affirmative.lowered(
					in:					&context,
					entryLabel:			intermediateAffirmative,
					affirmativeTarget:	affirmativeTarget,
					negativeTarget:		negativeTarget,
					previousEffects:	[]
				)
				let negativeBlocks = negative.lowered(
					in:					&context,
					entryLabel:			intermediateNegative,
					affirmativeTarget:	affirmativeTarget,
					negativeTarget:		negativeTarget,
					previousEffects:	[]
				)
				return conditionBlocks + affirmativeBlocks + negativeBlocks
				
				case .effectful(effect: _, finally: _):
				TODO.unimplemented
				
			}
		}
		
	}
	
	public typealias BranchRelation = Lower.BranchRelation
	
}
