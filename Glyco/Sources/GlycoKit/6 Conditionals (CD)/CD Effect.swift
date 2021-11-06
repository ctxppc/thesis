// Glyco © 2021 Constantino Tsarouhas

import Foundation

extension CD {
	
	/// An effect on an CD machine.
	public enum Effect : Codable {
		
		/// An effect that does nothing.
		case none
		
		/// An effect that retrieves the value in `source` and puts it in `destination`, then performs `successor`.
		indirect case copy(destination: Location, source: Source, successor: Effect)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `destination`, then performs `successor`.
		indirect case compute(destination: Location, lhs: Source, operation: BinaryOperator, rhs: Source, successor: Effect)
		
		/// An effect that performs `affirmative` if `predicate` holds, or `negative` otherwise (if not `nil`), then performs `successor`.
		indirect case conditional(predicate: Predicate, affirmative: Effect, negative: Effect, successor: Effect)
		
		/// An effect that terminates with `result`.
		case `return`(result: Source)
		
		/// Returns a representation of `self` in a lower language.
		///
		/// - Parameters:
		///    - context: The context in which `self` is being lowered.
		///    - entryLabel: The label of the entry block representing `self`.
		///    - previousEffects: Effects to be executed before executing `self`.
		///    - exitLabel: The label to jump to after executing `self` and any successors, or `nil` if `self` represents a program effect.
		///
		/// - Returns: A representation of `self` in a lower language.
		func lowered(in context: inout Context, entryLabel: Lower.Label, previousEffects: [Lower.Effect], exitLabel: Lower.Label?) throws -> [Lower.Block] {
			switch self {
				
				case .none:
				guard let exitLabel = exitLabel else { throw LoweringError.missingReturn }
				return [.intermediate(label: entryLabel, effects: previousEffects, successor: exitLabel)]
				
				case .copy(destination: let destination, source: let source, successor: let successor):
				return try successor.lowered(
					in:					&context,
					entryLabel:			entryLabel,
					previousEffects:	previousEffects + [.copy(destination: destination, source: source)],
					exitLabel:			exitLabel
				)
				
				case .compute(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs, successor: let successor):
				return try successor.lowered(
					in:					&context,
					entryLabel:			entryLabel,
					previousEffects:	previousEffects + [.compute(destination: destination, lhs: lhs, operation: operation, rhs: rhs)],
					exitLabel:			exitLabel
				)
				
				// conditional without (redundant empty) successor block — optimisation
				case .conditional(predicate: let predicate, affirmative: let affirmative, negative: let negative, successor: .none):
				let affirmativeLabel = context.allocateBlockLabel()
				let negativeLabel = context.allocateBlockLabel()
				let conditionalBlocks = predicate.lowered(
					in:					&context,
					entryLabel:			entryLabel,
					affirmativeTarget:	affirmativeLabel,
					negativeTarget:		negativeLabel,
					previousEffects:	previousEffects
				)
				let affirmativeBlocks = try affirmative.lowered(
					in:					&context,
					entryLabel:			affirmativeLabel,
					previousEffects:	[],
					exitLabel:			exitLabel
				)
				let negativeBlocks = try negative.lowered(
					in:					&context,
					entryLabel:			negativeLabel,
					previousEffects:	[],
					exitLabel:			exitLabel
				)
				return conditionalBlocks + affirmativeBlocks + negativeBlocks
				
				// conditional with successor block — general case
				case .conditional(predicate: let predicate, affirmative: let affirmative, negative: let negative, successor: let successor):
				let affirmativeLabel = context.allocateBlockLabel()
				let negativeLabel = context.allocateBlockLabel()
				let successorLabel = context.allocateBlockLabel()
				let conditionalBlocks = predicate.lowered(
					in:					&context,
					entryLabel:			entryLabel,
					affirmativeTarget:	affirmativeLabel,
					negativeTarget:		negativeLabel,
					previousEffects:	previousEffects
				)
				let affirmativeBlocks = try affirmative.lowered(
					in:					&context,
					entryLabel:			affirmativeLabel,
					previousEffects:	[],
					exitLabel:			successorLabel
				)
				let negativeBlocks = try negative.lowered(
					in:					&context,
					entryLabel:			negativeLabel,
					previousEffects:	[],
					exitLabel:			successorLabel
				)
				let successorBlocks = try successor.lowered(
					in:					&context,
					entryLabel:			successorLabel,
					previousEffects:	[],
					exitLabel:			exitLabel
				)
				return conditionalBlocks + affirmativeBlocks + negativeBlocks + successorBlocks
				
				case .return(result: let result):
				return [.final(label: entryLabel, effects: previousEffects, result: result)]
				
			}
		}
		
		enum LoweringError : LocalizedError {
			
			case missingReturn
			
			var errorDescription: String? {
				switch self {
					case .missingReturn:	return "Some execution paths end without a return effect."
				}
			}
			
		}
		
	}
	
	public typealias Location = Lower.Location
	public typealias BinaryOperator = Lower.BinaryOperator
	
}
