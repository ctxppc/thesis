// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit
import Foundation

extension CD {
	
	/// An effect on an CD machine.
	public enum Effect : Codable, Equatable {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(Location, to: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect)
		
		/// An effect that invokes the labelled procedure.
		///
		/// This effect assumes the calling convention is respected by the rest of the program.
		case call(Label)
		
		/// An effect that terminates the program with given result.
		case `return`(Source)
		
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
				
				case .do(let effects):
				return try effects.lowered(in: &context, entryLabel: entryLabel, previousEffects: previousEffects, exitLabel: exitLabel)
				
				case .call(let procedure):
				guard exitLabel == .programExit else { throw LoweringError.effectAfterInvocation }
				return [.intermediate(entryLabel, previousEffects, then: procedure)]
				
				case .set, .compute, .if, .return:
				return try [self].lowered(in: &context, entryLabel: entryLabel, previousEffects: previousEffects, exitLabel: exitLabel)
				
			}
		}
		
		/// A Boolean value indicating whether `self` is confirmed to have no effect.
		///
		/// - Returns: `true` if `self` has no effect; `false` if it cannot be determined that `self` has no effect.
		var doesNothing: Bool {
			switch self {
				
				case .do(let effects):
				return effects.allSatisfy(\.doesNothing)
				
				case .if(_, then: let affirmative, else: let negative):
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
				
				case .do(let effects):
				return effects
						.reversed()	// optimisation: it's most likely at the end
						.contains(where: \.allExecutionPathsTerminate)
				
				case .set, .compute:	// TODO: Add .invoke to this case when it becomes applicable.
				return false
				
				case .if(_, then: let affirmative, else: let negative):
				return affirmative.allExecutionPathsTerminate && negative.allExecutionPathsTerminate
				
				case .call, .return:	// TODO: Remove .invoke from this case when no longer applicable.
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
		///
		/// This method is more effective on flattened effects.
		func optimised() -> Self {
			switch self {
				
				case .set(let destination, to: .location(let source)) where source == destination,
					.compute(.location(let source), .add, .immediate(0), to: let destination) where source == destination,
					.compute(.immediate(0), .add, .location(let source), to: let destination) where source == destination,
					.compute(.location(let source), .subtract, .immediate(0), to: let destination) where source == destination,
					.compute(.immediate(0), .subtract, .location(let source), to: let destination) where source == destination:
				return .do([])
				
				case .if(.constant(true), then: let affirmative, else: _):
				return affirmative.optimised()
				
				case .if(.constant(false), then: _, else: let negative):
				return negative.optimised()
				
				case .if(let predicate, then: let affirmative, else: let negative):
				let newPredicate = predicate.optimised()
				let newConditional = Self.if(newPredicate, then: affirmative.optimised(), else: negative.optimised())
				return newPredicate == predicate ? newConditional : newConditional.optimised()
				
				default:
				return self
				
			}
		}
		
		/// Flattens nested sequence in `self`.
		func flattened() -> Self {
			switch self {
				
				case .do(effects: let effects):
				return .do(effects.flatMap { subeffect -> [Effect] in
					switch subeffect.flattened() {
						case .do(let nested):	return nested
						case let flattened:			return [flattened]
					}
				})
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return .if(predicate, then: affirmative.flattened(), else: negative.flattened())
				
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
		guard let (first, rest) = self.splittingFirst() else { return [.intermediate(entryLabel, previousEffects, then: exitLabel)] }
		switch first {
			
			case .do(effects: let effects) where rest.doesNothing:
			return try effects.lowered(in: &context, entryLabel: entryLabel, previousEffects: previousEffects, exitLabel: exitLabel)
			
			case .do(effects: let effects):
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
			
			case .set(let destination, to: let source):
			return try rest.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects + [.copy(from: source, to: destination)],
				exitLabel:			exitLabel
			)
			
			case .compute(let lhs, let operation, let rhs, to: let destination):
			return try rest.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects + [.compute(lhs, operation, rhs, to: destination)],
				exitLabel:			exitLabel
			)
			
			case .if(let predicate, then: let affirmative, else: let negative):
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
			
			case .call(procedure: let procedure):
			guard rest.isEmpty && exitLabel == .programExit else { throw CD.Effect.LoweringError.effectAfterInvocation }
			return [.intermediate(entryLabel, previousEffects, then: procedure)]
			
			case .return(result: let result):
			guard rest.doesNothing else { throw CD.Effect.LoweringError.effectAfterReturn }
			return [.final(entryLabel, previousEffects, result: result)]
			
		}
	}
	
}

public func <- (destination: CD.Location, source: CD.Source) -> CD.Effect {
	.set(destination, to: source)
}
