// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension FO {
	
	/// An effect on an FO machine.
	///
	/// As a convention, the following verbiage is used in the context of data movement:
	/// * a datum is *retrieved from* a source or location;
	/// * a datum is *put in* a location;
	/// * a datum is *copied from* a source or location *to* a location.
	public enum Effect : Codable, Equatable, MultiplyLowerable {
		
		/// An effect that copies the datum from `from` to `to`.
		///
		/// When `to` is an immediate, the data type cannot be `.capability`.
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
		
		/// An effect that jumps to `to` if *x* `relation` *y*, where *x* is the value of `lhs` and *y* is the value of `rhs`.
		case branch(to: Label, Source, BranchRelation, Source)
		
		/// An effect that jumps to given target.
		case jump(to: Label)
		
		/// An effect that calls the procedure with given name.
		case call(Label)
		
		/// An effect that returns control to the caller with given target code capability (which is usually `cra`).
		case `return`(to: Source)
		
		/// An effect that can jumped to using given label.
		indirect case labelled(Label, Effect)
		
		/// An effect that does nothing.
		public static var nop: Self { .compute(.register(.zero), .register(.zero), .add, .register(.zero)) }
		
		// See protocol.
		@ArrayBuilder<Lower.Effect>
		public func lowered(in context: inout ()) throws -> [Lower.Effect] {
			switch self {
				
				case .set(.u8, .register(let dest), to: .constant(let value)):
				try Lower.Effect.put(into: dest.lowered(), value: .init(UInt8(truncatingIfNeeded: value)))
				
				case .set(.s32, .register(let dest), to: .constant(let value)):
				try Lower.Effect.put(into: dest.lowered(), value: value)
				
				case .set(.cap, .register, to: .constant(let value)):
				throw LoweringError.settingCapabilityUsingConstant(value)
				
				case .set(let type, .register(let dest), to: .register(let src)):
				try Lower.Effect.copy(type, into: dest.lowered(), from: src.lowered())
				
				case .set(let type, .register(let dest), to: .frame(let src)):
				Lower.Effect.load(type, into: try dest.lowered(), from: src)
				
				case .set(.cap, .register(let dest), to: .capability(to: let label)):
				Lower.Effect.deriveCapability(in: try dest.lowered(), to: label)
				
				case .set(.cap, .frame, to: .constant(let value)):
				throw LoweringError.settingCapabilityUsingConstant(value)
				
				case .set(let type, .frame(let dest), to: .constant(let value)):
				Lower.Effect.put(into: tempRegisterA, value: value)
				Lower.Effect.store(type, into: dest, from: tempRegisterA)
				
				case .set(let type, .frame(let dest), to: .register(let src)):
				try Lower.Effect.store(type, into: dest, from: src.lowered())
				
				case .set(let type, .frame(let dest), to: .frame(let src)):
				Lower.Effect.load(type, into: tempRegisterA, from: src)
				Lower.Effect.store(type, into: dest, from: tempRegisterA)
				
				case .set(.cap, .frame(let dest), to: .capability(to: let label)):
				Lower.Effect.deriveCapability(in: tempRegisterA, to: label)
				Lower.Effect.store(.cap, into: dest, from: tempRegisterA)
				
				case .set(let dataType, _, to: .capability(to: let label)):
				throw LoweringError.settingNoncapabilityToLabel(dataType, label)
				
				case .compute(let destination, let lhs, .mul, .constant(let rhs)):
				let (loadLHS, lhs) = try load(.s32, from: lhs, using: tempRegisterA)
				let (storeResult, dest) = try store(.s32, to: destination, using: tempRegisterB)
				Lower.Effect.put(into: tempRegisterA, value: rhs)
				loadLHS
				Lower.Effect.compute(destination: dest, lhs, .mul, .register(tempRegisterA))
				storeResult
				
				case .compute(let destination, let lhs, let operation, .constant(let rhs)):
				let (loadLHS, lhs) = try load(.s32, from: lhs, using: tempRegisterA)
				let (storeResult, dest) = try store(.s32, to: destination, using: tempRegisterB)
				loadLHS
				Lower.Effect.compute(destination: dest, lhs, operation, .constant(rhs))
				storeResult
				
				case .compute(let destination, .constant(let lhs), .add, .register(let rhs)):
				try Self.compute(destination, .register(rhs), .add, .constant(lhs)).lowered()
				
				case .compute(let destination, let lhs, let operation, let rhs):
				let (loadLHS, lhs) = try load(.s32, from: lhs, using: tempRegisterA)
				let (loadRHS, rhs) = try loadAsSource(.s32, from: rhs, using: tempRegisterB)
				let (storeResult, dest) = try store(.s32, to: destination, using: tempRegisterA)
				loadLHS
				loadRHS
				Lower.Effect.compute(destination: dest, lhs, operation, rhs)
				storeResult
				
				case .createBuffer(bytes: let bytes, capability: let buffer, onFrame: let onFrame):
				let (storeBufferCap, bufferCap) = try store(.cap, to: buffer, using: tempRegisterA)
				Lower.Effect.createBuffer(bytes: .constant(bytes), capability: bufferCap, onFrame: onFrame)
				storeBufferCap
				
				case .destroyBuffer(capability: let buffer):
				let (loadBufferCap, bufferCap) = try load(.cap, from: buffer, using: tempRegisterA)
				loadBufferCap
				Lower.Effect.destroyBuffer(capability: bufferCap)
				
				case .getElement(let type, of: let buffer, offset: let offset, to: let destination):
				let (loadBuffer, buffer) = try load(type, from: .init(buffer), using: tempRegisterA)
				let (loadOffset, offset) = try loadAsSource(type, from: offset, using: tempRegisterB)
				let (storeElement, dest) = try store(type, to: destination, using: tempRegisterA)
				loadBuffer
				loadOffset
				Lower.Effect.loadElement(type, into: dest, buffer: buffer, offset: offset)
				storeElement
				
				case .setElement(let type, of: let vector, offset: let offset, to: let element):
				let (loadBuffer, buffer) = try load(type, from: .init(vector), using: tempRegisterA)
				let (loadOffset, offset) = try loadAsSource(type, from: offset, using: tempRegisterB)
				let (loadElement, element) = try load(type, from: element, using: .invocationData)	// FIXME: Register not reserved by MM!
				loadBuffer
				loadOffset
				loadElement
				Lower.Effect.storeElement(type, buffer: buffer, offset: offset, from: element)
				
				case .pushFrame(let frame):
				Lower.Effect.pushFrame(frame)
				
				case .popFrame:
				Lower.Effect.popFrame
				
				case .clearAll(except: let sparedRegisters):
				Lower.Effect.clearAll(except: try sparedRegisters.lowered())
				
				case .branch(to: let target, let lhs, let relation, let rhs):
				let (loadLHS, lhs) = try load(.s32, from: lhs, using: tempRegisterA)
				let (loadRHS, rhs) = try load(.s32, from: rhs, using: tempRegisterB)
				loadLHS
				loadRHS
				Lower.Effect.branch(to: target, lhs, relation, rhs)
				
				case .jump(to: let target):
				Lower.Effect.jump(to: .label(target))
				
				case .call(let label):
				Lower.Effect.call(label)
				
				case .return(to: .constant(let value)):
				throw LoweringError.returningToConstant(value)
				
				case .return(to: .capability(to: let caller)):
				Lower.Effect.return(to: .label(caller))
				
				case .return(to: .register(let caller)):
				Lower.Effect.return(to: .register(try caller.lowered()))
				
				case .return(to: .frame(let caller)):
				Lower.Effect.load(.cap, into: tempRegisterA, from: caller)
				Lower.Effect.return(to: .register(tempRegisterA))
				
				case .labelled(let label, let effect):
				if let (first, tail) = try effect.lowered().splittingFirst() {
					Lower.Effect.labelled(label, first)
					tail
				} else {
					Lower.Effect.labelled(label, .nop)
				}
				
			}
		}
		
		/// Loads the datum in `source` in `temporaryRegister` if `source` isn't a register.
		///
		/// No loads with overlapping lifetimes may use the same `temporaryRegister`.
		///
		/// - Returns: A pair consisting of the effects to perform before the main effect, and the register where the loaded datum is located.
		private func load(_ dataType: DataType, from source: Source, using temporaryRegister: Lower.Register) throws -> ([Lower.Effect], Lower.Register) {
			switch source {
				
				case .constant(let value):
				return ([.put(into: temporaryRegister, value: value)], temporaryRegister)
				
				case .register(let register):
				return ([], try register.lowered())
				
				case .frame(let location):
				return ([.load(dataType, into: temporaryRegister, from: location)], temporaryRegister)
				
				case .capability(to: let label):
				guard dataType == .cap else { throw LoweringError.settingNoncapabilityToLabel(dataType, label) }
				return ([.deriveCapability(in: temporaryRegister, to: label)], temporaryRegister)
				
			}
		}
		
		/// Loads the datum in `source` in `temporaryRegister` if `source` isn't a register or constant value.
		///
		/// No loads with overlapping lifetimes may use the same `temporaryRegister`.
		///
		/// - Returns: A pair consisting of the effects to perform before the main effect, and the source from which the datum can be retrieved.
		private func loadAsSource(_ dataType: DataType, from source: Source, using temporaryRegister: Lower.Register) throws -> ([Lower.Effect], Lower.Source) {
			switch source {
				
				case .constant(let value):
				return ([], .constant(value))
				
				case .register, .frame, .capability:
				let (effects, register) = try load(dataType, from: source, using: temporaryRegister)
				return (effects, .register(register))
				
			}
		}
		
		/// Stores the datum in `temporaryRegister` in `destination` if `destination` isn't a register.
		///
		/// A load whose lifetime ends on the store may use the same `temporaryRegister` as the store.
		///
		/// - Returns: A pair consisting of the effects to perform after the main effect, and the register wherein to put the result of the effect.
		private func store(_ type: DataType, to destination: Location, using temporaryRegister: Lower.Register) throws -> ([Lower.Effect], Lower.Register) {
			switch destination {
				case .register(let r):	return ([], try r.lowered())
				case .frame(let c):		return ([.store(type, into: c, from: temporaryRegister)], temporaryRegister)
			}
		}
		
		enum LoweringError : LocalizedError {
			
			/// An error indicating that a return is being attempt using a constant.
			case returningToConstant(Int)
			
			/// An error indicating that a capability is being set using a constant.
			case settingCapabilityUsingConstant(Int)
			
			/// An error indicating that a non-capability is being set to capability to a labelled memory location.
			case settingNoncapabilityToLabel(DataType, Label)
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					
					case .returningToConstant(let value):
					return "Cannot return to the constant value \(value)"
					
					case .settingCapabilityUsingConstant(let value):
					return "Cannot set a capability location using the constant value \(value)"
					
					case .settingNoncapabilityToLabel(let dataType, let label):
					return "Cannot set a location typed \(dataType) to a capability to a memory location labelled “\(label)”"
					
				}
			}
		}
		
	}
	
}
