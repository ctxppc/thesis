// Glyco © 2021–2022 Constantino Tsarouhas

extension MM {
	
	/// An MM effect.
	public enum Effect : Codable, Equatable, MultiplyLowerable {
		
		/// An effect that copies the contents from `from` to `into`.
		case copy(DataType, into: Register, from: Register)
		
		/// An effect that computes given expression and puts the result in given register.
		case compute(Register, BinaryExpression)
		
		/// An effect that loads the datum in the frame at `from` and puts it in `into`.
		case load(DataType, into: Register, from: Frame.Location)
		
		/// An effect that retrieves the datum from `from` and stores it in the frame at `into`.
		case store(DataType, into: Frame.Location, from: Register)
		
		/// An effect that allocates a buffer of `bytes` bytes and puts a capability for that buffer in given register.
		///
		/// If `onFrame` is `true` and the call stack is enabled, the buffer is allocated on the call frame and automatically deallocated when the frame is popped, after which it must not be accessed.
		case createBufferWithImmediate(bytes: Int, capability: Register, onFrame: Bool)
		
		/// An effect that allocates a buffer of *b* bytes, where *b* is in `bytes`, and puts a capability for that buffer in `capability`.
		///
		/// If `onFrame` is `true` and the call stack is enabled, the buffer is allocated on the call frame and automatically deallocated when the frame is popped, after which it must not be accessed.
		case createBufferWithRegister(bytes: Register, capability: Register, onFrame: Bool)
		
		/// An effect that deallocates the buffer referred by the capability in given register.
		///
		/// This effect must only be used with buffers allocated in the current call frame. For any two buffers *a* and *b* allocated in the current call frame, *b* must be deallocated exactly once before deallocating *a*. Deallocation is not required before popping the call frame; in that case, deallocation is automatic. This effect does nothing if the call stack is disabled.
		case destroyBuffer(capability: Register)
		
		/// An effect that loads the datum at byte offset `offset` in the buffer at `buffer` and puts it in `into`.
		case loadElement(DataType, into: Register, buffer: Register, offset: Register)
		
		/// An effect that retrieves the datum from `from` and stores it at byte offset `offset` in the buffer at `buffer`.
		case storeElement(DataType, buffer: Register, offset: Register, from: Register)
		
		/// An effect that pushes given frame to the call stack by pushing `cfp` to the stack, copying `csp` to `cfp`, and offsetting `csp` *b* bytes downward, where *b* is the byte size allocated by the frame.
		///
		/// This effect must be executed exactly once before any effects accessing the call frame.
		case pushFrame(Frame)
		
		/// An effect that pops a frame by copying `cfp` to `csp` and popping `cfp` from the stack.
		///
		/// This effect must be executed exactly once before any effects accessing the previous call frame.
		case popFrame
		
		/// An effect that derives a capability from `source`, keeping at most the specified permissions, and puts it in `source`.
		///
		/// The capability in `destination` contains a permission *p* iff *p* is in the capability in `source` **and** if *p* is among the specified permissions.
		///
		/// A hardware exception is raised if `source` doesn't contain a valid, unsealed capability.
		case permit([Permission], destination: Register, source: Register)
		
		/// An effect that clears given registers.
		case clear([Register])
		
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
		static var nop: Self { .compute(.zero, Register.zero + .zero) }
		
		// See protocol.
		@StatementsBuilder
		func lowered(in context: inout Context) throws -> [Lower.Statement] {
			let temp = Lower.Register.t0
			switch self {
				
				case .copy(.u8, into: let destination, from: let source),	// TODO: Copy u8 as s32 then mask out upper bits.
					.copy(.s32, into: let destination, from: let source):
				try Lower.Instruction.copyWord(destination: destination.lowered(), source: source.lowered())
				
				case .copy(.cap, into: let destination, from: let source):
				try Lower.Instruction.copyCapability(destination: destination.lowered(), source: source.lowered())
				
				case .compute(let destination, .registerRegister(let rs1, let operation, let rs2)):
				try Lower.Instruction.computeWithRegister(operation: operation, rd: destination.lowered(), rs1: rs1.lowered(), rs2: rs2.lowered())
				
				case .compute(let destination, .registerImmediate(let rs1, let operation, let imm)):
				try Lower.Instruction.computeWithImmediate(operation: operation, rd: destination.lowered(), rs1: rs1.lowered(), imm: imm)
				
				case .load(.u8, into: let destination, from: let source):
				Lower.Instruction.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: source.offset)
				Lower.Instruction.loadByte(destination: try destination.lowered(), address: temp)
				
				case .load(.s32, into: let destination, from: let source):
				Lower.Instruction.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: source.offset)
				Lower.Instruction.loadSignedWord(destination: try destination.lowered(), address: temp)
				
				case .load(.cap, into: let destination, from: let source):
				Lower.Instruction.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: source.offset)
				Lower.Instruction.loadCapability(destination: try destination.lowered(), address: temp)
				
				case .store(.u8, into: let destination, from: let source):
				Lower.Instruction.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: destination.offset)
				Lower.Instruction.storeByte(source: try source.lowered(), address: temp)
				
				case .store(.s32, into: let destination, from: let source):
				Lower.Instruction.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: destination.offset)
				Lower.Instruction.storeSignedWord(source: try source.lowered(), address: temp)
				
				case .store(.cap, into: let destination, from: let source):
				Lower.Instruction.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: destination.offset)
				Lower.Instruction.storeCapability(source: try source.lowered(), address: temp)
				
				case .createBufferWithImmediate(bytes: let bytes, capability: let buffer, onFrame: false):
				Lower.Instruction.computeWithImmediate(operation: .add, rd: .t0, rs1: .zero, imm: bytes)
				Lower.Instruction.deriveCapabilityFromLabel(destination: .t1, label: .allocationRoutineCapability)
				Lower.Instruction.jumpWithRegister(target: .t1)
				Lower.Instruction.copyCapability(destination: try buffer.lowered(), source: .t0)
				
				case .createBufferWithImmediate(bytes: let bytes, capability: let buffer, onFrame: true):
				if context.configuration.callingConvention.callStackEnabled {
					
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
					
					// Derive buffer capability (without bounding it yet).
					let buffer = try buffer.lowered()
					Lower.Instruction.offsetCapabilityWithImmediate(destination: buffer, source: .sp, offset: -bytes)
					
					// Restrict its bounds. Its base might move downwards, its length might increase.
					Lower.Instruction.setCapabilityBoundsWithImmediate(destination: buffer, source: buffer, length: bytes)
					
					// Move stack capability over the allocated region.
					Lower.Instruction.getCapabilityAddress(destination: temp, source: buffer)
					Lower.Instruction.setCapabilityAddress(destination: .sp, source: .sp, address: temp)
					
				} else {
					try Self.createBufferWithImmediate(bytes: bytes, capability: buffer, onFrame: false).lowered(in: &context)
				}
				
				case .createBufferWithRegister(bytes: let bytesReg, capability: let buffer, onFrame: false):
				Lower.Instruction.computeWithRegister(operation: .add, rd: .t0, rs1: .zero, rs2: try bytesReg.lowered())
				Lower.Instruction.deriveCapabilityFromLabel(destination: .t1, label: .allocationRoutineCapability)
				Lower.Instruction.jumpWithRegister(target: .t1)
				Lower.Instruction.copyCapability(destination: try buffer.lowered(), source: .t0)
				
				case .createBufferWithRegister(bytes: let bytesReg, capability: let buffer, onFrame: true):
				if context.configuration.callingConvention.callStackEnabled {
					
					// Derive buffer capability (without bounding it yet).
					let bytesReg = try bytesReg.lowered()
					let buffer = try buffer.lowered()
					Lower.Instruction.computeWithRegister(operation: .sub, rd: temp, rs1: .zero, rs2: bytesReg)
					Lower.Instruction.offsetCapability(destination: buffer, source: .sp, offset: temp)
					
					// Restrict its bounds. Its base might move downwards, its length might increase.
					Lower.Instruction.setCapabilityBounds(destination: buffer, source: buffer, length: bytesReg)
					
					// Move stack capability over the allocated region.
					Lower.Instruction.getCapabilityAddress(destination: temp, source: buffer)
					Lower.Instruction.setCapabilityAddress(destination: .sp, source: .sp, address: temp)
					
				} else {
					try Self.createBufferWithRegister(bytes: bytesReg, capability: buffer, onFrame: false).lowered(in: &context)
				}
				
				case .destroyBuffer(let buffer):
				if context.configuration.callingConvention.callStackEnabled {
					Lower.Instruction.getCapabilityLength(destination: temp, source: try buffer.lowered())
					Lower.Instruction.offsetCapability(destination: .sp, source: .sp, offset: temp)
				}
				
				case .loadElement(.u8, into: let destination, buffer: let buffer, offset: let offset):
				try Lower.Instruction.offsetCapability(destination: destination.lowered(), source: buffer.lowered(), offset: offset.lowered())
				try Lower.Instruction.loadByte(destination: destination.lowered(), address: destination.lowered())
				
				case .loadElement(.s32, into: let destination, buffer: let buffer, offset: let offset):
				try Lower.Instruction.offsetCapability(destination: destination.lowered(), source: buffer.lowered(), offset: offset.lowered())
				try Lower.Instruction.loadSignedWord(destination: destination.lowered(), address: destination.lowered())
				
				case .loadElement(.cap, into: let destination, buffer: let buffer, offset: let offset):
				try Lower.Instruction.offsetCapability(destination: destination.lowered(), source: buffer.lowered(), offset: offset.lowered())
				try Lower.Instruction.loadCapability(destination: destination.lowered(), address: destination.lowered())
				
				case .storeElement(.u8, buffer: let buffer, offset: let offset, from: let source):
				try Lower.Instruction.offsetCapability(destination: temp, source: buffer.lowered(), offset: offset.lowered())
				try Lower.Instruction.storeByte(source: source.lowered(), address: temp)
				
				case .storeElement(.s32, buffer: let buffer, offset: let offset, from: let source):
				try Lower.Instruction.offsetCapability(destination: temp, source: buffer.lowered(), offset: offset.lowered())
				try Lower.Instruction.storeSignedWord(source: source.lowered(), address: temp)
				
				case .storeElement(.cap, buffer: let buffer, offset: let offset, from: let source):
				try Lower.Instruction.offsetCapability(destination: temp, source: buffer.lowered(), offset: offset.lowered())
				try Lower.Instruction.storeCapability(source: source.lowered(), address: temp)
				
				case .pushFrame(let frame):
				do {
					
					// Save previous fp — defer updating sp since fp is already included in the allocated byte size.
					Lower.Instruction.offsetCapabilityWithImmediate(destination: temp, source: .sp, offset: -DataType.cap.byteSize)
					Lower.Instruction.storeCapability(source: .fp, address: temp)
					
					// Set up fp for new frame — using deferred sp.
					Lower.Instruction.copyCapability(destination: .fp, source: temp)
					
					// Allocate space for frame by pushing sp downward.
					Lower.Instruction.offsetCapabilityWithImmediate(destination: .sp, source: .sp, offset: -frame.allocatedByteSize)
					
				}

				case .popFrame:
				do {
					
					// Pop frame and saved fp by moving sp one word above the saved fp's location.
					Lower.Instruction.offsetCapabilityWithImmediate(destination: .sp, source: .fp, offset: +DataType.cap.byteSize)
					
					// Restore saved fp — follow the linked list.
					Lower.Instruction.loadCapability(destination: .fp, address: .fp)
					
				}
				
				case .permit(let permissions, destination: let destination, source: let source):
				let destination = try destination.lowered()
				Lower.Instruction.computeWithImmediate(operation: .add, rd: destination, rs1: .zero, imm: Int(permissions.bitmask))
				Lower.Instruction.permit(destination: destination, source: try source.lowered(), mask: destination)
				
				case .clear(let registers):
				let registersByQuarter = Dictionary(grouping: registers, by: { $0.ordinal / 8 })
				let masksByQuarter = registersByQuarter.mapValues { registers -> UInt8 in
					registers
						.lazy
						.map { 1 << ($0.ordinal % 8) }
						.reduce(0, |)
				}
				for (quarter, mask) in masksByQuarter {
					Lower.Instruction.clear(quarter: quarter, mask: mask)
				}
				
				case .branch(to: let target, let rs1, let relation, let rs2):
				try Lower.Instruction.branch(rs1: rs1.lowered(), relation: relation, rs2: rs2.lowered(), target: target)
				
				case .jump(to: let target):
				Lower.Instruction.jump(target: target)
				
				case .call(let label):
				Lower.Instruction.call(target: label)
				
				case .return:
				Lower.Instruction.return
				
				case .labelled(let label, let effect):
				if let (first, tail) = try effect.lowered(in: &context).splittingFirst() {
					Lower.Statement.labelled(label, first)
					tail
				}
				
			}
		}
		
	}
	
}

extension MM.Label {
	
	/// The label for the capability to the allocation routine.
	static var allocationRoutineCapability: Self { "mm.alloc.cap" }
	
}
