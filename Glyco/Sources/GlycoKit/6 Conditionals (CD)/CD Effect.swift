// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension CD {
	
	/// An effect on an CD machine.
	public enum Effect : Codable, Equatable, Optimisable {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(DataType, Location, to: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
		/// An effect that pushes a vector of `count` elements to the call frame and puts a capability for that vector in `into`.
		case allocateVector(DataType, count: Int = 1, into: Location)
		
		/// An effect that retrieves the element at zero-based position `at` in the vector in `of` and puts it in `to`.
		case getElement(DataType,of: Location, at: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(DataType,of: Location, at: Source, to: Source)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect)
		
		/// Pushes a frame of size `bytes` bytes to the call stack by copying `csp` to `cfp` then offsetting `csp` by `bytes` bytes downward.
		///
		/// This effect must be executed exactly once before any effects accessing the call frame.
		case pushFrame(bytes: Int)
		
		/// Pops a frame by copying `cfp` to `csp` then restoring `cfp` to the capability stored in `savedFrameCapability`.
		///
		/// This effect must be executed exactly once before any effects accessing the previous call frame.
		case popFrame(savedFrameCapability: Frame.Location)
		
		/// An effect that invokes the labelled procedure.
		///
		/// This effect assumes the calling convention is respected by the rest of the program.
		case call(Label)
		
		/// An effect that terminates the program with given result.
		case `return`(DataType, Source)
		
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
				
				case .set, .compute, .allocateVector, .getElement, .setElement, .if, .pushFrame, .popFrame, .return:
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
				
				case .set, .compute, .allocateVector, .getElement, .setElement, .pushFrame, .popFrame:	// TODO: Add .call to this case when it becomes applicable.
				return false
				
				case .if(_, then: let affirmative, else: let negative):
				return affirmative.allExecutionPathsTerminate && negative.allExecutionPathsTerminate
				
				case .call, .return:	// TODO: Remove .call from this case when no longer applicable.
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
		
		// See protocol.
		@discardableResult
		public mutating func optimise() -> Bool {
			switch self {
				
				case .do(var effects):
				let optimised = effects.optimise()
				self = .do(effects)
				return optimised
				
				case .set(_, let destination, to: .location(let source)) where source == destination,
					.compute(.location(let source), .add, .immediate(0), to: let destination) where source == destination,
					.compute(.immediate(0), .add, .location(let source), to: let destination) where source == destination,
					.compute(.location(let source), .sub, .immediate(0), to: let destination) where source == destination,
					.compute(.immediate(0), .sub, .location(let source), to: let destination) where source == destination:
				self = .do([])
				return true
				
				case .if(.constant(true), then: var affirmative, else: _):
				affirmative.optimise()
				self = affirmative
				return true
				
				case .if(.constant(false), then: _, else: var negative):
				negative.optimise()
				self = negative
				return true
				
				case .if(var predicate, then: var affirmative, else: var negative):
				let conditionOptimised = predicate.optimise()
				let affirmativeOptimised = affirmative.optimise()
				let negativeOptimised = negative.optimise()
				self = .if(predicate, then: affirmative, else: negative)
				return conditionOptimised || affirmativeOptimised || negativeOptimised
				
				default:
				return false
				
			}
		}
		
		/// Flattens nested `do` effects in `self`.
		func flattened() -> Self {
			switch self {
				
				case .do(effects: let effects):
				return .do(effects.flatMap { subeffect -> [Effect] in
					switch subeffect.flattened() {
						case .do(let nested):	return nested
						case let flattened:		return [flattened]
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
			let restLabel = context.bag.uniqueName(from: "then")
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
			
			case .set(let type, let destination, to: let source):
			return try rest.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects + [.set(type, destination, to: source)],
				exitLabel:			exitLabel
			)
			
			case .compute(let lhs, let operation, let rhs, to: let destination):
			return try rest.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects + [.compute(lhs, operation, rhs, to: destination)],
				exitLabel:			exitLabel
			)
			
			case .allocateVector(let type, count: let count, into: let vector):
			return try rest.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects + [.allocateVector(type, count: count, into: vector)],
				exitLabel:			exitLabel
			)
			
			case .getElement(let type, of: let vector, at: let index, to: let destination):
			return try rest.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects + [.getElement(type, of: vector, at: index, to: destination)],
				exitLabel:			exitLabel
			)
			
			case .setElement(let type, of: let vector, at: let index, to: let element):
			return try rest.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects + [.setElement(type, of: vector, at: index, to: element)],
				exitLabel:			exitLabel
			)
			
			case .if(let predicate, then: let affirmative, else: let negative):
			let affirmativeLabel = context.bag.uniqueName(from: "then")
			let negativeLabel = context.bag.uniqueName(from: "else")
			let restLabel = rest.doesNothing ? exitLabel : context.bag.uniqueName(from: "endif")
			let conditionalBlocks = try predicate.lowered(
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
			
			case .pushFrame(bytes: let bytes):
			return try rest.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects + [.pushFrame(bytes: bytes)],
				exitLabel:			exitLabel
			)
			
			case .popFrame(savedFrameCapability: let savedFrameCapability):
			return try rest.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects + [.popFrame(savedFrameCapability: savedFrameCapability)],
				exitLabel:			exitLabel
			)
			
			case .call(procedure: let procedure):
			guard rest.isEmpty && exitLabel == .programExit else { throw CD.Effect.LoweringError.effectAfterInvocation }
			return [.intermediate(entryLabel, previousEffects, then: procedure)]
			
			case .return(let type, let result):
			guard rest.doesNothing else { throw CD.Effect.LoweringError.effectAfterReturn }
			return [.final(entryLabel, previousEffects, result: result, type: type)]
			
		}
	}
	
}
