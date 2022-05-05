// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension CD {
	
	/// An effect on an CD machine.
	public enum Effect : Optimisable, ComposableEffect {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(DataType, Location, to: Source)
		
		/// An effect that computes given expression and puts the result in given location.
		case compute(Location, Source, BinaryOperator, Source)
		
		/// An effect that allocates a buffer of `bytes` bytes and puts a capability for that buffer in given location.
		///
		/// If `onFrame` is `true`, the buffer may be allocated on the call frame and may be automatically deallocated when the frame is popped, after which it must not be accessed.
		case createBuffer(bytes: Int, capability: Location, onFrame: Bool)
		
		/// An effect that deallocates the buffer referred by the capability from given source.
		///
		/// This effect must only be used with buffers allocated in the current call frame. For any two buffers *a* and *b* allocated in the current call frame, *b* must be deallocated exactly once before deallocating *a*. Deallocation is not required before popping the call frame; in that case, deallocation is automatic.
		case destroyBuffer(capability: Source)
		
		/// An effect that retrieves the datum at offset `offset` in the buffer in `of` and puts it in `to`.
		case getElement(DataType, of: Location, offset: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the buffer in `of` at offset `offset`.
		case setElement(DataType, of: Location, offset: Source, to: Source)
		
		/// An effect that creates a capability that can be used for sealing with a unique object type and puts it in given location.
		case createSeal(in: Location)
		
		/// An effect that seals the capability in `source` using the sealing capability in `seal` and puts it in `into`.
		case seal(into: Location, source: Location, seal: Location)
		
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
		
		/// An effect that clears all registers except the structural registers `csp`, `cgp`, `ctp`, and `cfp` as well as given registers.
		case clearAll(except: [Register])
		
		/// An effect that calls the procedure with given target code capability.
		case call(Source)
		
		/// An effect that calls the procedure with given target code capability and data capability (both sealed with the same object type).
		case callSealed(Source, data: Source)
		
		/// An effect that returns control to the caller with given target code capability (which is usually `cra`).
		case `return`(to: Source)
		
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
				
				case .set, .compute,
					.createBuffer, .destroyBuffer,
					.getElement, .setElement,
					.createSeal, .seal,
					.if,
					.pushFrame, .popFrame,
					.clearAll,
					.call, .callSealed, .return:
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
				
				case .set, .compute,
					.createBuffer, .destroyBuffer,
					.getElement, .setElement,
					.createSeal, .seal,
					.pushFrame, .popFrame,
					.clearAll,
					.call, .callSealed:
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
		public mutating func optimise(configuration: CompilationConfiguration) throws -> Bool {
			switch self {
				
				case .do(var effects):
				let optimised = try effects.optimise(configuration: configuration)
				self = .do(effects)
				return optimised
				
				case .set(_, let destination, to: let source) where source.location == destination,
						.compute(let destination, let source, .add, .constant(0)) where source.location == destination,
						.compute(let destination, .constant(0), .add, let source) where source.location == destination,
						.compute(let destination, let source, .sub, .constant(0)) where source.location == destination,
						.compute(let destination, .constant(0), .sub, let source) where source.location == destination:
				self = .do([])
				return true
				
				case .if(.constant(true), then: var affirmative, else: _):
				try affirmative.optimise(configuration: configuration)
				self = affirmative
				return true
				
				case .if(.constant(false), then: _, else: var negative):
				try negative.optimise(configuration: configuration)
				self = negative
				return true
				
				case .if(var predicate, then: var affirmative, else: var negative):
				let conditionOptimised = try predicate.optimise(configuration: configuration)
				let affirmativeOptimised = try affirmative.optimise(configuration: configuration)
				let negativeOptimised = try negative.optimise(configuration: configuration)
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
		func simpleLowering(_ loweredEffect: CD.Lower.Effect) throws -> [CD.Lower.Block] {
			try rest.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects + [loweredEffect],
				exitLabel:			exitLabel
			)
		}
		
		switch first {
			
			case .do(effects: let effects) where rest.doesNothing:
			return try effects.lowered(in: &context, entryLabel: entryLabel, previousEffects: previousEffects, exitLabel: exitLabel)
			
			case .do(effects: let effects):
			let restLabel = context.labels.uniqueName(from: "then")
			return try effects.lowered(
				in:					&context,
				entryLabel:			entryLabel,
				previousEffects:	previousEffects,
				exitLabel:			restLabel
			) + rest.lowered(
				in:					&context,
				entryLabel:			restLabel,
				previousEffects:	[],
				exitLabel:			exitLabel
			)
			
			case .set(let type, let destination, to: let source):
			return try simpleLowering(.set(type, destination, to: source))
			
			case .compute(let destination, let lhs, let operation, let rhs):
			return try simpleLowering(.compute(destination, lhs, operation, rhs))
				
			case .createBuffer(bytes: let bytes, capability: let buffer, onFrame: let onFrame):
			return try simpleLowering(.createBuffer(bytes: bytes, capability: buffer, onFrame: onFrame))
			
			case .destroyBuffer(let buffer):
			return try simpleLowering(.destroyBuffer(capability: buffer))
			
			case .getElement(let type, of: let vector, offset: let offset, to: let destination):
			return try simpleLowering(.getElement(type, of: vector, offset: offset, to: destination))
			
			case .setElement(let type, of: let vector, offset: let offset, to: let element):
			return try simpleLowering(.setElement(type, of: vector, offset: offset, to: element))
			
			case .createSeal(in: let destination):
			return try simpleLowering(.createSeal(in: destination))
			
			case .seal(into: let destination, source: let source, seal: let seal):
			return try simpleLowering(.seal(into: destination, source: source, seal: seal))
			
			case .if(let predicate, then: let affirmative, else: let negative):
			let affirmativeLabel = context.labels.uniqueName(from: "then")
			let negativeLabel = context.labels.uniqueName(from: "else")
			let restLabel = rest.doesNothing ? exitLabel : context.labels.uniqueName(from: "endif")
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
			return try simpleLowering(.pushFrame(frame))
			
			case .popFrame:
			return try simpleLowering(.popFrame)
			
			case .clearAll(except: let sparedRegisters):
			return try simpleLowering(.clearAll(except: sparedRegisters))
			
			case .call(let procedure):
			let returnPoint = context.labels.uniqueName(from: "ret")
			return try [.init(name: entryLabel, do: previousEffects, then: .call(procedure, returnPoint: returnPoint))]
				+ rest.lowered(in: &context, entryLabel: returnPoint, previousEffects: [], exitLabel: exitLabel)
			
			case .callSealed(let procedure, data: let data):
			let returnPoint = context.labels.uniqueName(from: "ret")
			return try [.init(name: entryLabel, do: previousEffects, then: .callSealed(procedure, data: data, returnPoint: returnPoint))]
				+ rest.lowered(in: &context, entryLabel: returnPoint, previousEffects: [], exitLabel: exitLabel)
			
			case .return(to: let caller):
			return [.init(name: entryLabel, do: previousEffects, then: .return(to: caller))]
			
		}
	}
	
}
