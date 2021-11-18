// Glyco © 2021 Constantino Tsarouhas

import DepthKit
import Foundation

extension CD {
	
	/// An effect on an CD machine.
	public enum Effect : Codable, Equatable {
		
		/// An effect that performs `effects`.
		case sequence(effects: [Effect])
		
		/// An effect that retrieves the value in `source` and puts it in `destination`.
		case copy(destination: Location, source: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `destination`.
		case compute(destination: Location, lhs: Source, operation: BinaryOperator, rhs: Source)
		
		/// An effect that performs `affirmative` if `predicate` holds, or `negative` otherwise.
		indirect case conditional(predicate: Predicate, affirmative: Effect, negative: Effect)
		
		/// An effect that invokes the procedure labelled `procedure`.
		///
		/// This effect assumes the calling convention is respected by the rest of the program.
		case invoke(procedure: Label)
		
		/// An effect that terminates the program with `result`.
		case `return`(result: Source)
		
		/// Returns a representation of `self` in a lower language.
		///
		/// - Parameters:
		///    - context: The context in which `self` is being lowered.
		///    - entryLabel: The label of the entry block representing `self`.
		///    - previousEffects: Effects to be executed before executing `self`.
		///    - exitLabel: The label to jump to after executing `self` and any successors.
		///
		/// - Returns: A representation of `self` in a lower language.
		func lowered(in context: inout Context, entryLabel: Lower.Label, previousEffects: [Lower.Effect], exitLabel: Lower.Label) throws -> [Lower.Block] {
			switch self {
				
				case .sequence(effects: let effects):
				return try effects.lowered(in: &context, entryLabel: entryLabel, previousEffects: previousEffects, exitLabel: exitLabel)
				
				case .invoke(procedure: let procedure):
				guard exitLabel == .programExit else { throw LoweringError.effectAfterInvocation }
				return [.intermediate(label: entryLabel, effects: previousEffects, successor: procedure)]
				
				case .copy, .compute, .conditional, .return:
				return try [self].lowered(in: &context, entryLabel: entryLabel, previousEffects: previousEffects, exitLabel: exitLabel)
				
			}
		}
		
		/// A Boolean value indicating whether `self` is confirmed to have no effect.
		///
		/// - Returns: `true` if `self` has no effect; `false` if it cannot be determined that `self` has no effect.
		var doesNothing: Bool {
			switch self {
				
				case .sequence(effects: let effects):
				return effects.allSatisfy(\.doesNothing)
				
				case .conditional(predicate: _, affirmative: let affirmative, negative: let negative):
				return affirmative.doesNothing && negative.doesNothing
				
				default:
				return false
				
			}
		}
		
		/// A Boolean value indicating whether `self` always terminates the program or procedure.
		///
		/// - Returns: `true` if `self` always terminates the program or procedure; `false` otherwise.
		var allExecutionPathsTerminate: Bool {
			switch self {
				
				case .sequence(effects: let effects):
				return effects
						.reversed()	// optimisation: it's most likely at the end
						.contains(where: \.allExecutionPathsTerminate)
				
				case .copy, .compute:	// TODO: Add .invoke to this case when it becomes applicable.
				return false
				
				case .conditional(predicate: _, affirmative: let affirmative, negative: let negative):
				return affirmative.allExecutionPathsTerminate && negative.allExecutionPathsTerminate
				
				case .invoke, .return:	// TODO: Remove .invoke from this case when no longer applicable.
				return true
				
			}
		}
		
		enum LoweringError : LocalizedError {
			
			/// An error indicating that some execution paths contain an intermediate invocation effect.
			case effectAfterInvocation
			
			/// An error indicating that some execution paths contain an intermediate return effect.
			case effectAfterReturn
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					case .effectAfterInvocation:	return "Some execution paths contain an intermediate invocation effect."
					case .effectAfterReturn:		return "Some execution paths contain an intermediate return effect."
				}
			}
			
		}
		
		/// Returns a copy of `self` that may be more optimised.
		func optimised() -> Self {
			switch self {
				
				case .copy(destination: let destination, source: .location(let source)) where source == destination,
					.compute(destination: let destination, lhs: .location(let source), operation: .add, rhs: .immediate(0)) where source == destination,
					.compute(destination: let destination, lhs: .immediate(0), operation: .add, rhs: .location(let source)) where source == destination,
					.compute(destination: let destination, lhs: .location(let source), operation: .subtract, rhs: .immediate(0)) where source == destination,
					.compute(destination: let destination, lhs: .immediate(0), operation: .subtract, rhs: .location(let source)) where source == destination:
				return .sequence(effects: [])
				
				case .conditional(predicate: .constant(true), affirmative: let affirmative, negative: _):
				return affirmative.optimised()
				
				case .conditional(predicate: .constant(false), affirmative: _, negative: let negative):
				return negative.optimised()
				
				case .conditional(predicate: let predicate, affirmative: let affirmative, negative: let negative):
				let newPredicate = predicate.optimised()
				let newConditional = Self.conditional(predicate: newPredicate, affirmative: affirmative.optimised(), negative: negative.optimised())
				return newPredicate == predicate ? newConditional : newConditional.optimised()
				
				default:
				return self
				
			}
		}
	}
	
}

private extension RandomAccessCollection where Element == CD.Effect {
	
	/// A Boolean value indicating whether the effects in `self` are confirmed to have no effect.
	///
	/// - Returns: `true` if the effects in `self` have no effect; `false` if it cannot be determined that the effects in `self` have no effect.
	private var doesNothing: Bool {
		allSatisfy(\.doesNothing)
	}
	
	/// Lowers the sequence of effects to a lower language.
	///
	/// - Parameters:
	///    - context: The context in which `self` is being lowered.
	///    - entryLabel: The label of the lowered entry block.
	///    - previousEffects: Effects to be executed before executing `self`.
	///    - exitLabel: The label to jump to after executing `self`.
	///
	/// - Returns: A representation of `self` in a lower language.
	func lowered(in context: inout CD.Context, entryLabel: CD.Lower.Label, previousEffects: [CD.Lower.Effect], exitLabel: CD.Lower.Label) throws -> [CD.Lower.Block] {
		guard let (first, rest) = self.splittingFirst() else { return [.intermediate(label: entryLabel, effects: previousEffects, successor: exitLabel)] }
		switch first {
			
			case .sequence(effects: let effects) where rest.doesNothing:
			return try effects.lowered(in: &context, entryLabel: entryLabel, previousEffects: previousEffects, exitLabel: exitLabel)
			
			case .sequence(effects: let effects):
			let restLabel = context.allocateBlockLabel()
			return try effects.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	[],
				exitLabel:			restLabel
			) + rest.lowered(
				in:					&context,
				entryLabel:			restLabel,
				previousEffects:	[],
				exitLabel:			exitLabel
			)
			
			case .copy(destination: let destination, source: let source):
			return try rest.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects + [.copy(destination: destination, source: source)],
				exitLabel:			exitLabel
			)
			
			case .compute(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs):
			return try rest.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects + [.compute(destination: destination, lhs: lhs, operation: operation, rhs: rhs)],
				exitLabel:			exitLabel
			)
			
			case .conditional(predicate: let predicate, affirmative: let affirmative, negative: let negative):
			let affirmativeLabel = context.allocateBlockLabel()
			let negativeLabel = context.allocateBlockLabel()
			let restLabel = rest.doesNothing ? exitLabel : context.allocateBlockLabel()
			let conditionalBlocks = predicate.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects,
				affirmativeTarget:	affirmative.doesNothing ? restLabel : affirmativeLabel,
				negativeTarget:		negative.doesNothing ? restLabel : negativeLabel
			)
			let affirmativeBlocks = affirmative.doesNothing ? [] : try affirmative.lowered(
				in:					&context,
				entryLabel:			affirmativeLabel,
				previousEffects:	[],
				exitLabel:			restLabel
			)
			let negativeBlocks = negative.doesNothing ? [] : try negative.lowered(
				in:					&context,
				entryLabel:			negativeLabel,
				previousEffects:	[],
				exitLabel:			restLabel
			)
			let restBlocks = rest.doesNothing ? [] : try rest.lowered(
				in:					&context,
				entryLabel:			restLabel,
				previousEffects:	[],
				exitLabel:			exitLabel
			)
			return conditionalBlocks + affirmativeBlocks + negativeBlocks + restBlocks
			
			case .invoke(procedure: let procedure):
			guard rest.isEmpty && exitLabel == .programExit else { throw CD.Effect.LoweringError.effectAfterInvocation }
			return [.intermediate(label: entryLabel, effects: previousEffects, successor: procedure)]
			
			case .return(result: let result):
			guard rest.doesNothing else { throw CD.Effect.LoweringError.effectAfterReturn }
			return [.final(label: entryLabel, effects: previousEffects, result: result)]
			
		}
	}
	
}
