// Glyco © 2021 Constantino Tsarouhas

extension CD {
	
	/// An effect on an CD machine.
	public enum Effect : Codable {
		
		/// An effect that retrieves the value in `source` and puts it in `destination`, then performs `successor`.
		indirect case copy(destination: Location, source: Source, successor: Effect)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `destination`, then performs `successor`.
		indirect case compute(destination: Location, lhs: Source, operation: BinaryOperator, rhs: Source, successor: Effect)
		
		/// An effect that performs `affirmative` if `predicate` holds, or `negative` otherwise.
		indirect case conditional(predicate: Predicate, affirmative: Effect, negative: Effect)
		
		/// An effect that terminates with `result`.
		case `return`(result: Source)
		
		/// Returns a representation of `self` in a lower language.
		///
		/// - Parameters:
		///    - context: The context in which `self` is being lowered.
		///    - entryLabel: The label of the entry block representing `self`.
		///    - previousEffects: Effects to be executed before executing `self`.
		///
		/// - Returns: A representation of `self` in a lower language.
		func lowered(in context: inout Context, entryLabel: Lower.Label, previousEffects: [Lower.Effect]) -> [Lower.Block] {
			switch self {
				
				case .copy(destination: let destination, source: let source, successor: let successor):
				return successor.lowered(
					in:					&context,
					entryLabel:			entryLabel,
					previousEffects:	previousEffects + [.copy(destination: destination, source: source)]
				)
				
				case .compute(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs, successor: let successor):
				return successor.lowered(
					in:					&context,
					entryLabel:			entryLabel,
					previousEffects:	previousEffects + [.compute(destination: destination, lhs: lhs, operation: operation, rhs: rhs)]
				)
				
				case .conditional(predicate: let predicate, affirmative: let affirmative, negative: let negative):
				let intermediateAffirmative = context.allocateBlockLabel()
				let intermediateNegative = context.allocateBlockLabel()
				let conditionalBlocks = predicate.lowered(
					in:					&context,
					entryLabel:			entryLabel,
					affirmativeTarget:	intermediateAffirmative,
					negativeTarget:		intermediateNegative,
					previousEffects:	previousEffects
				)
				let affirmativeBlocks = affirmative.lowered(in: &context, entryLabel: intermediateAffirmative, previousEffects: [])
				let negativeBlocks = negative.lowered(in: &context, entryLabel: intermediateNegative, previousEffects: [])
				return conditionalBlocks + affirmativeBlocks + negativeBlocks
				
				case .return(result: let result):
				return [.final(label: entryLabel, effects: previousEffects, result: result)]
				
			}
		}
		
	}
	
	public typealias Location = Lower.Location
	public typealias BinaryOperator = Lower.BinaryOperator
	
}
