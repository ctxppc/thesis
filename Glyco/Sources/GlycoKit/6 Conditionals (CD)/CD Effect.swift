// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension CD {
	
	/// An effect on an CD machine.
	public enum Effect : ComposableEffect, Codable, Equatable, Optimisable {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(DataType, Location, to: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
		/// An effect that pushes a buffer of `bytes` bytes to the call frame and puts a capability for that buffer in given location.
		case pushBuffer(bytes: Int, into: Location)
		
		/// An effect that pops the buffer referred by the capability from given source.
		///
		/// This effect must only be used with buffers allocated in the current call frame. For any two buffers *a* and *b* allocated in the current call frame, *b* must be deallocated exactly once before deallocating *a*. Deallocation is not required before popping the call frame; in that case, deallocation is automatic.
		case popBuffer(Source)
		
		/// An effect that retrieves the datum at offset `offset` in the buffer in `of` and puts it in `to`.
		case getElement(DataType, of: Location, offset: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the buffer in `of` at offset `offset`.
		case setElement(DataType, of: Location, offset: Source, to: Source)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect)
		
		/// Pushes given frame to the call stack.
		///
		/// This effect must be executed exactly once before any effects accessing the call frame.
		case pushFrame(Frame)
		
		/// Pops a frame from the call stack.
		///
		/// This effect must be executed exactly once before any effects accessing the previous call frame.
		case popFrame
		
		/// An effect that invokes the labelled procedure.
		///
		/// This effect assumes the calling convention is respected by the rest of the program.
		case call(Label)
		
		/// An effect that returns to the caller.
		///
		/// This effect assumes the calling convention is respected by the rest of the program.
		case `return`
		
		/// Returns a representation of `self` in a lower language.
		///
		/// - Parameters:
		///    - context: The context in which `self` is being lowered.
		///    - entryLabel: The name of the entry block representing `self`.
		///    - previousEffects: Effects to be executed before executing `self`.
		///    - exitLabel: The name of the block to jump to after executing `self` and its successors.
		///
		/// - Returns: A representation of `self` in a lower language.
		func lowered(in context: inout Context, entryLabel: Lower.Block.Name, previousEffects: [Lower.Effect], exitLabel: Lower.Block.Name) throws -> [Lower.Block] {
			switch self {
				
				case .do(let effects):
				return try effects.lowered(in: &context, entryLabel: entryLabel, previousEffects: previousEffects, exitLabel: exitLabel)
				
				case .set, .compute, .pushBuffer, .popBuffer, .getElement, .setElement, .if, .pushFrame, .popFrame, .call, .return:
				return try [self].lowered(in: &context, entryLabel: entryLabel, previousEffects: previousEffects, exitLabel: exitLabel)
				
			}
		}
		
		/// A Boolean value indicating whether `self` is known to have no effect.
		///
		/// - Returns: `true` if `self` has no effect, or `false` if this cannot be determined.
		var doesNothing: Bool {
			switch self {
				
				case .do(let effects):
				return effects.doesNothing
				
				case .if(_, then: let affirmative, else: let negative):
				return affirmative.doesNothing && negative.doesNothing
				
				default:
				return false
				
			}
		}
		
		/// A Boolean value indicating whether every execution path in `self` contains a return effect.
		///
		/// - Returns: `true` if every execution path in `self` contains a return effect; `false` otherwise.
		var returns: Bool {
			switch self {
				
				case .do(let effects):
				return effects
						.reversed()	// optimisation: it's most likely at the end
						.contains(where: \.returns)
				
				case .set, .compute, .pushBuffer, .popBuffer, .getElement, .setElement, .pushFrame, .popFrame, .call:
				return false
				
				case .if(_, then: let affirmative, else: let negative):
				return affirmative.returns && negative.returns
				
				case .return:
				return true
				
			}
		}
		
		enum LoweringError : LocalizedError {
			
			/// An error indicating that some execution paths contain an intermediate return effect.
			case effectAfterReturn
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					case .effectAfterReturn:
					return "Some execution paths contain an intermediate return effect."
				}
			}
			
		}
		
		// See protocol.
		var subeffects: [Self]? {
			guard case .do(let subeffects) = self else { return nil }
			return subeffects
		}
		
		// See protocol.
		@discardableResult
		public mutating func optimise() throws -> Bool {
			switch self {
				
				case .do(var effects):
				let optimised = try effects.optimise()
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
				try affirmative.optimise()
				self = affirmative
				return true
				
				case .if(.constant(false), then: _, else: var negative):
				try negative.optimise()
				self = negative
				return true
				
				case .if(var predicate, then: var affirmative, else: var negative):
				let conditionOptimised = try predicate.optimise()
				let affirmativeOptimised = try affirmative.optimise()
				let negativeOptimised = try negative.optimise()
				self = .if(predicate, then: affirmative, else: negative)
				return conditionOptimised || affirmativeOptimised || negativeOptimised
				
				default:
				return false
				
			}
		}
		
	}
	
}

fileprivate extension RandomAccessCollection where Element == CD.Effect {
	
	/// A Boolean value indicating whether the effects in `self` are confirmed to have no effect.
	///
	/// - Returns: `true` if the effects in `self` have no effect; `false` if it cannot be determined that the effects in `self` have no effect.
	var doesNothing: Bool {
		allSatisfy(\.doesNothing)
	}
	
	/// Lowers the sequence of effects to a lower language.
	///
	/// - Parameters:
	///    - context: The context in which `self` is being lowered.
	///    - entryLabel: The name of the lowered entry block.
	///    - previousEffects: Effects to be executed before executing `self`.
	///    - exitLabel: The name of the block to jump to after executing `self`.
	///
	/// - Returns: A representation of `self` in a lower language.
	func lowered(in context: inout CD.Context, entryLabel: CD.Lower.Label, previousEffects: [CD.Lower.Effect], exitLabel: CD.Lower.Label) throws -> [CD.Lower.Block] {
		guard let (first, rest) = self.splittingFirst() else { return [.init(name: entryLabel, do: previousEffects, then: .continue(to: exitLabel))] }
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
			
			case .pushBuffer(bytes: let bytes, into: let buffer):
			return try rest.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects + [.pushBuffer(bytes: bytes, into: buffer)],
				exitLabel:			exitLabel
			)
			
			
			case .popBuffer(let buffer):
			return try rest.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects + [.popBuffer(buffer)],
				exitLabel:			exitLabel
			)
			
			case .getElement(let type, of: let vector, offset: let offset, to: let destination):
			return try rest.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects + [.getElement(type, of: vector, offset: offset, to: destination)],
				exitLabel:			exitLabel
			)
			
			case .setElement(let type, of: let vector, offset: let offset, to: let element):
			return try rest.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects + [.setElement(type, of: vector, offset: offset, to: element)],
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
			
			case .pushFrame(let frame):
			return try rest.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects + [.pushFrame(frame)],
				exitLabel:			exitLabel
			)
			
			case .popFrame:
			return try rest.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects + [.popFrame],
				exitLabel:			exitLabel
			)
			
			case .call(let procedure):
			let returnPoint = context.bag.uniqueName(from: "ret")
			return try [.init(name: entryLabel, do: previousEffects, then: .call(procedure, returnPoint: returnPoint))]
				+ rest.lowered(in: &context, entryLabel: returnPoint, previousEffects: [], exitLabel: exitLabel)
			
			case .return:
			return [.init(name: entryLabel, do: previousEffects, then: .return)]
			
		}
	}
	
}
