// Glyco © 2021–2022 Constantino Tsarouhas

extension CF {
	
	/// An effect on an FL machine.
	public enum Effect : Codable, Equatable, MultiplyLowerable {
		
		/// An effect that copies the contents from `from` to `into`.
		case copy(DataType, into: Register, from: Register)
		
		/// An effect that computes `value` and puts the result in `into`.
		case compute(into: Register, value: BinaryExpression)
		
		/// An effect that loads the datum in the frame at `from` and puts it in `into`.
		case load(DataType, into: Register, from: Frame.Location)
		
		/// An effect that retrieves the datum from `from` and stores it in the frame at `into`.
		case store(DataType, into: Frame.Location, from: Register)
		
		/// An effect that pushes a buffer of `bytes` bytes to the call frame and puts a capability for that buffer in given register.
		case pushBuffer(bytes: Int, into: Register)
		
		/// An effect that pops the buffer referred by the capability in given register.
		///
		/// This effect must only be used with buffers allocated in the current call frame. For any two buffers *a* and *b* allocated in the current call frame, *b* must be deallocated exactly once before deallocating *a*. Deallocation is not required before popping the call frame; in that case, deallocation is automatic.
		case popBuffer(Register)
		
		/// An effect that loads the datum at byte offset `offset` in the buffer at `buffer` and puts it in `into`.
		case loadElement(DataType, into: Register, buffer: Register, offset: Register)
		
		/// An effect that retrieves the datum from `from` and stores it at byte offset `offset` in the buffer at `buffer`.
		case storeElement(DataType, buffer: Register, offset: Register, from: Register)
		
		/// Pushes given frame to the call stack by pushing `cfp` to the stack, copying `csp` to `cfp`, and offsetting `csp` *b* bytes downward, where *b* is the byte size allocated by the frame.
		///
		/// This effect must be executed exactly once before any effects accessing the call frame.
		case pushFrame(Frame)
		
		/// Pops a frame by copying `cfp` to `csp` and popping `cfp` from the stack.
		///
		/// This effect must be executed exactly once before any effects accessing the previous call frame.
		case popFrame
		
		/// An effect that jumps to `to` if *x* *R* *y*, where *x* and *y* are given registers and *R* is given relation.
		case branch(to: Label, Register, BranchRelation, Register)
		
		/// An effect that jumps to `to`.
		case jump(to: Label)
		
		/// An effect that puts the next PCC in `cra`, then jumps to given label.
		case call(Label)
		
		/// An effect that jumps to address *x*, where *x* is the value in `cra`.
		case `return`
		
		/// An effect that can jumped to using given label.
		indirect case labelled(Label, Effect)
		
		/// An effect that does nothing.
		static var nop: Self { .compute(into: .zero, value: Register.zero + .zero) }
		
		// See protocol.
		func lowered(in context: inout ()) throws -> [Lower.Instruction] {
			let temp = Lower.Register.t0
			switch self {
				
				case .copy(.u8, into: let destination, from: let source),	// TODO: Copy u8 as s32 then mask out upper bits.
					.copy(.s32, into: let destination, from: let source):
				return try [.copyWord(destination: destination.lowered(), source: source.lowered())]
				
				case .copy(.cap, into: let destination, from: let source):
				return try [.copyCapability(destination: destination.lowered(), source: source.lowered())]
				
				case .compute(into: let destination, value: .registerRegister(let rs1, let operation, let rs2)):
				return try [.registerRegister(operation: operation, rd: destination.lowered(), rs1: rs1.lowered(), rs2: rs2.lowered())]
				
				case .compute(into: let destination, value: .registerImmediate(let rs1, let operation, let imm)):
				return try [.registerImmediate(operation: operation, rd: destination.lowered(), rs1: rs1.lowered(), imm: imm)]
				
				case .load(.u8, into: let destination, from: let source):
				return [
					.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: source.offset),
					.loadByte(destination: try destination.lowered(), address: temp)
				]
				
				case .load(.s32, into: let destination, from: let source):
				return [
					.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: source.offset),
					.loadSignedWord(destination: try destination.lowered(), address: temp)
				]
				
				case .load(.cap, into: let destination, from: let source):
				return [.loadCapability(destination: try destination.lowered(), address: .fp, offset: source.offset)]
				
				case .store(.u8, into: let destination, from: let source):
				return [
					.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: destination.offset),
					.storeByte(source: try source.lowered(), address: temp)
				]
				
				case .store(.s32, into: let destination, from: let source):
				return [
					.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: destination.offset),
					.storeSignedWord(source: try source.lowered(), address: temp)
				]
				
				case .store(.cap, into: let destination, from: let source):
				return [.storeCapability(source: try source.lowered(), address: temp, offset: destination.offset)]
				
				case .pushBuffer(bytes: let bytes, into: let buffer):
				/*
					 ┌──────────┐ high
					 │          │
					 │          │◄───── previous sp
					 │ ┌──────┐ │
					 │ │ …    │ │
					 │ │ 3    │ │
					 │ │ 2    │ │
					 │ │ 1    │ │
					 │ │ 0    │ │◄───── buffer & new sp
					 │ └──────┘ │
					 │          │
					 └──────────┘ low
				 */
				let buffer = try buffer.lowered()
				return [
					.offsetCapabilityWithImmediate(destination: buffer, source: .sp, offset: -bytes),	// compute tentative base
					.setCapabilityBounds(destination: buffer, source: buffer, length: bytes),			// actual base may be lower, length may be greater
					.getCapabilityAddress(destination: temp, source: buffer),							// move stack capability
					.setCapabilityAddress(destination: .sp, source: .sp, address: temp),				//   to actual base
				]
				
				case .popBuffer(let buffer):
				return [
					.getCapabilityLength(destination: temp, source: try buffer.lowered()),
					.offsetCapability(destination: .sp, source: .sp, offset: temp),
				]
				
				case .loadElement(.u8, into: let destination, buffer: let buffer, offset: let offset):
				return try [
					.offsetCapability(destination: destination.lowered(), source: buffer.lowered(), offset: offset.lowered()),
					.loadByte(destination: destination.lowered(), address: destination.lowered()),
				]
				
				case .loadElement(.s32, into: let destination, buffer: let buffer, offset: let offset):
				return try [
					.offsetCapability(destination: destination.lowered(), source: buffer.lowered(), offset: offset.lowered()),
					.loadSignedWord(destination: destination.lowered(), address: destination.lowered()),
				]
				
				case .loadElement(.cap, into: let destination, buffer: let buffer, offset: let offset):
				return try [
					.offsetCapability(destination: destination.lowered(), source: buffer.lowered(), offset: offset.lowered()),
					.loadCapability(destination: destination.lowered(), address: destination.lowered(), offset: 0),
				]
				
				case .storeElement(.u8, buffer: let buffer, offset: let offset, from: let source):
				return try [
					.offsetCapability(destination: temp, source: buffer.lowered(), offset: offset.lowered()),
					.storeByte(source: source.lowered(), address: temp),
				]
				
				case .storeElement(.s32, buffer: let buffer, offset: let offset, from: let source):
				return try [
					.offsetCapability(destination: temp, source: buffer.lowered(), offset: offset.lowered()),
					.storeSignedWord(source: source.lowered(), address: temp),
				]
				
				case .storeElement(.cap, buffer: let buffer, offset: let offset, from: let source):
				return try [
					.offsetCapability(destination: temp, source: buffer.lowered(), offset: offset.lowered()),
					.storeCapability(source: source.lowered(), address: temp, offset: 0),
				]
				
				case .pushFrame(let frame):
				let frameCapOffsetBeforeStackCapUpdate = -DataType.cap.byteSize
				return [
					
					// Push fp but defer sp update.
					.storeCapability(source: .fp, address: .sp, offset: frameCapOffsetBeforeStackCapUpdate),
					
					// Set up fp for new frame using virtually updated sp.
					.offsetCapabilityWithImmediate(destination: .fp, source: .sp, offset: frameCapOffsetBeforeStackCapUpdate),
					
					// Actually update sp, for both saved fp and requested frame size.
					.offsetCapabilityWithImmediate(destination: .sp, source: .sp, offset: -(DataType.cap.byteSize + frame.allocatedByteSize)),
					
				]

				case .popFrame:
				return [
					
					// Pop frame and saved fp by moving sp one word above the saved fp's location.
					.offsetCapabilityWithImmediate(destination: .sp, source: .fp, offset: +DataType.cap.byteSize),
					
					// Restore saved fp — follow the linked list.
					.loadCapability(destination: .fp, address: .fp, offset: 0)
					
				]
				
				case .branch(to: let target, let rs1, let relation, let rs2):
				return try [.branch(rs1: rs1.lowered(), relation: relation, rs2: rs2.lowered(), target: target)]
				
				case .jump(to: let target):
				return [.jump(target: target)]
				
				case .call(let label):
				return [.call(target: label)]
				
				case .return:
				return [.return]
				
				case .labelled(let label, let instruction):
				guard let (first, tail) = try instruction.lowered(in: &context).splittingFirst() else { return [] /* should never happen — famous last words */ }
				return [.labelled(label, first)].appending(contentsOf: tail)
				
			}
		}
		
	}
	
}
