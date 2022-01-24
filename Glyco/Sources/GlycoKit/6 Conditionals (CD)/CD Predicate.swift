// Glyco © 2021–2022 Constantino Tsarouhas

extension CD {
	
	/// A value that can be used in a conditional.
	public enum Predicate : Codable, Equatable, Optimisable {
		
		/// A constant predicate.
		case constant(Bool)
		
		/// A predicate that holds iff *x* *R* *y*, where *R* is the relation, *x* is the value of the first source, and *y* is the value of the second source.
		case relation(Source, BranchRelation, Source)
		
		/// A predicate that evaluates to `then` if the first given predicate holds, or to `else` otherwise.
		indirect case `if`(Predicate, then: Predicate, else: Predicate)
		
		/// A predicate that performs some effect then evaluates to `then`.
		indirect case `do`([Effect], then: Predicate)
		
		// See protocol.
		@discardableResult
		public mutating func optimise() -> Bool {
			switch self {
				
				case .constant:
				return false
				
				case .relation(.immediate(let lhs), let relation, .immediate(let rhs)):
				self = .constant(relation.holds(lhs, rhs))
				return true
				
				case .relation(let lhs, let relation, let rhs) where lhs == rhs:
				self = .constant(relation.reflexive)
				return true
				
				case .relation:
				return false
				
				case .if(.constant(true), then: var affirmative, else: _):
				affirmative.optimise()
				self = affirmative
				return true
				
				case .if(.constant(false), then: _, else: var negative):
				negative.optimise()
				self = negative
				return true
				
				case .if(var condition, then: var affirmative, else: var negative):
				let conditionOptimised = condition.optimise()
				let affirmativeOptimised = affirmative.optimise()
				let negativeOptimised = negative.optimise()
				self = .if(condition, then: affirmative, else: negative)
				return conditionOptimised || affirmativeOptimised || negativeOptimised
				
				case .do(var effects, then: var predicate):
				let effectsOptimised = effects.optimise()
				let predicateOptimised = predicate.optimise()
				self = .do(effects, then: predicate)
				return effectsOptimised || predicateOptimised
				
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
		) throws -> [Lower.Block] {
			switch self {
				
				case .constant(let holds):
				return [.intermediate(entryLabel, previousEffects, then: holds ? affirmativeTarget : negativeTarget)]
				
				case .relation(let lhs, let relation, let rhs):
				return [.branch(entryLabel, previousEffects, if: .relation(lhs, relation, rhs), then: affirmativeTarget, else: negativeTarget)]
				
				case .if(let condition, then: let affirmative, else: let negative):
				let intermediateAffirmative = context.allocateBlockLabel()
				let intermediateNegative = context.allocateBlockLabel()
				let conditionBlocks = try condition.lowered(
					in:					&context,
					entryLabel:			entryLabel,
					previousEffects:	previousEffects,
					affirmativeTarget:	intermediateAffirmative,
					negativeTarget:		intermediateNegative
				)
				let affirmativeBlocks = try affirmative.lowered(
					in:					&context,
					entryLabel:			intermediateAffirmative,
					previousEffects:	[],
					affirmativeTarget:	affirmativeTarget,
					negativeTarget:		negativeTarget
				)
				let negativeBlocks = try negative.lowered(
					in:					&context,
					entryLabel:			intermediateNegative,
					previousEffects:	[],
					affirmativeTarget:	affirmativeTarget,
					negativeTarget:		negativeTarget
				)
				return conditionBlocks + affirmativeBlocks + negativeBlocks
				
				case .do(let effects, then: let predicate):
				let predicateLabel = context.allocateBlockLabel()
				return try Effect.do(effects).lowered(
					in:					&context,
					entryLabel:			entryLabel,
					previousEffects:	previousEffects,
					exitLabel:			predicateLabel
				) + predicate.lowered(
					in:					&context,
					entryLabel:			predicateLabel,
					previousEffects:	[],
					affirmativeTarget:	affirmativeTarget,
					negativeTarget:		negativeTarget
				)
				
			}
		}
		
	}
	
}
