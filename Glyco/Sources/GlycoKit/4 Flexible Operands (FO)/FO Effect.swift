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
		
		/// An effect that clears given registers.
		case clear([Register])
		
		/// An effect that jumps to `to` if *x* `relation` *y*, where *x* is the value of `lhs` and *y* is the value of `rhs`.
		case branch(to: Label, Source, BranchRelation, Source)
		
		/// An effect that jumps to `to`.
		case jump(to: Label)
		
		/// An effect that links the return address then jumps to `target`.
		case call(Label)
		
		/// An effect that jumps to the previously linked return address.
		case `return`
		
		/// An effect that can jumped to using given label.
		indirect case labelled(Label, Effect)
		
		/// An effect that does nothing.
		public static var nop: Self { .compute(.register(.zero), .register(.zero), .add, .register(.zero)) }
		
		// See protocol.
		@ArrayBuilder<Lower.Effect>
		public func lowered(in context: inout ()) throws -> [Lower.Effect] {
			let temp1 = Lower.Register.t3
			let temp2 = Lower.Register.t4
			let temp3 = Lower.Register.t5
			switch self {
				
				case .set(.u8, .register(let dest), to: .constant(let imm)):
				try Lower.Effect.put(into: dest.lowered(), value: .init(UInt8(truncatingIfNeeded: imm)))
				
				case .set(.s32, .register(let dest), to: .constant(let imm)):
				try Lower.Effect.put(into: dest.lowered(), value: imm)
				
				case .set(.cap, .register, to: .constant):
				throw LoweringError.settingCapabilityUsingImmediate
				
				case .set(let type, .register(let dest), to: .register(let src)):
				try Lower.Effect.copy(type, into: dest.lowered(), from: src.lowered())
				
				case .set(let type, .register(let dest), to: .frame(let src)):
				try Lower.Effect.load(type, into: dest.lowered(), from: src)
				
				case .set(.cap, .frame, to: .constant):
				throw LoweringError.settingCapabilityUsingImmediate
				
				case .set(let type, .frame(let dest), to: .constant(let imm)):
				Lower.Effect.put(into: temp1, value: imm)
				Lower.Effect.store(type, into: dest, from: temp1)
				
				case .set(let type, .frame(let dest), to: .register(let src)):
				try Lower.Effect.store(type, into: dest, from: src.lowered())
				
				case .set(let type, .frame(let dest), to: .frame(let src)):
				Lower.Effect.load(type, into: temp1, from: src)
				Lower.Effect.store(type, into: dest, from: temp1)
				
				case .compute(let destination, let lhs, let operation, .constant(let rhs)):
				let (loadLHS, lhs) = try load(.s32, from: lhs, using: temp1)
				let (storeResult, dest) = try store(.s32, to: destination, using: temp2)
				loadLHS
				Lower.Effect.compute(destination: dest, lhs, operation, .constant(rhs))
				storeResult
				
				case .compute(let destination, let lhs, let operation, let rhs):
				let (loadLHS, lhs) = try load(.s32, from: lhs, using: temp1)
				let (loadRHS, rhs) = try load(.s32, from: rhs, using: temp2)
				let (storeResult, dest) = try store(.s32, to: destination, using: temp3)
				loadLHS
				loadRHS
				Lower.Effect.compute(destination: dest, lhs, operation, .register(rhs))
				storeResult
				
				case .createBuffer(bytes: let bytes, capability: let buffer, onFrame: let onFrame):
				let (storeBufferCap, bufferCap) = try store(.cap, to: buffer, using: temp1)
				Lower.Effect.createBuffer(bytes: .constant(bytes), capability: bufferCap, onFrame: onFrame)
				storeBufferCap
				
				case .destroyBuffer(capability: let buffer):
				let (loadBufferCap, bufferCap) = try load(.cap, from: buffer, using: temp1)
				loadBufferCap
				Lower.Effect.destroyBuffer(capability: bufferCap)
				
				case .getElement(let type, of: let buffer, offset: let offset, to: let destination):
				let (loadBuffer, buffer) = try load(type, from: .init(buffer), using: temp1)
				let (loadOffset, offset) = try load(type, from: offset, using: temp2)
				let (storeElement, dest) = try store(type, to: destination, using: temp3)
				loadBuffer
				loadOffset
				Lower.Effect.loadElement(type, into: dest, buffer: buffer, offset: offset)
				storeElement
				
				case .setElement(let type, of: let vector, offset: let offset, to: let element):
				let (loadBuffer, buffer) = try load(type, from: .init(vector), using: temp1)
				let (loadOffset, offset) = try load(type, from: offset, using: temp2)
				let (loadElement, element) = try load(type, from: element, using: temp3)
				loadBuffer
				loadOffset
				loadElement
				Lower.Effect.storeElement(type, buffer: buffer, offset: offset, from: element)
				
				case .pushFrame(let frame):
				Lower.Effect.pushFrame(frame)
				
				case .popFrame:
				Lower.Effect.popFrame
				
				case .branch(to: let target, let lhs, let relation, let rhs):
				let (loadLHS, lhs) = try load(.s32, from: lhs, using: temp1)
				let (loadRHS, rhs) = try load(.s32, from: rhs, using: temp2)
				loadLHS
				loadRHS
				Lower.Effect.branch(to: target, lhs, relation, rhs)
				
				case .jump(to: let target):
				Lower.Effect.jump(to: .label(target), link: .zero)
				
				case .clear(let registers):
				Lower.Effect.clear(try registers.lowered())
				
				case .call(let label):
				Lower.Effect.call(label)
				
				case .return:
				Lower.Effect.return
				
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
		/// - Returns: A pair consisting of the instructions to perform before the main effect, and the register where the loaded datum is located.
		private func load(_ type: DataType, from source: Source, using temporaryRegister: Lower.Register) throws -> ([Lower.Effect], Lower.Register) {
			switch source {
				case .constant(let imm):	return ([.put(into: temporaryRegister, value: imm)], temporaryRegister)
				case .register(let r):		return ([], try r.lowered())
				case .frame(let c):			return ([.load(type, into: temporaryRegister, from: c)], temporaryRegister)
			}
		}
		
		/// Stores the datum in `temporaryRegister` in `destination` if `destination` isn't a register.
		///
		/// - Returns: A pair consisting of the instructions to perform after the main effect, and the register wherein to put the result of the effect.
		private func store(_ type: DataType, to destination: Location, using temporaryRegister: Lower.Register) throws -> ([Lower.Effect], Lower.Register) {
			switch destination {
				case .register(let r):	return ([], try r.lowered())
				case .frame(let c):		return ([.store(type, into: c, from: temporaryRegister)], temporaryRegister)
			}
		}
		
		enum LoweringError : LocalizedError {
			case settingCapabilityUsingImmediate
			var errorDescription: String? {
				switch self {
					case .settingCapabilityUsingImmediate:	return "Cannot set a capability register or frame cell using an immediate"
				}
			}
		}
		
	}
	
}
