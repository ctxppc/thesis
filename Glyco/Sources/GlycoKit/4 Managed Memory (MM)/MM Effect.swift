// Glyco © 2021–2022 Constantino Tsarouhas

extension MM {
	
	/// An MM effect.
	public enum Effect : Codable, Equatable, MultiplyLowerable {
		
		/// An effect that copies the contents from `from` to `into`.
		case copy(DataType, into: Register, from: Register)
		
		/// An effect that performs *x* `operation` *y* where *x* is the value in the second given register and *y* is the value from given source, and puts in `destination`.
		case compute(destination: Register, Register, BinaryOperator, Source)
		
		/// Returns an effect that puts `value` in `destination`.
		static func put(into destination: Register, value: Int) -> Self { .compute(destination: destination, .zero, .add, .constant(value)) }
		
		/// An effect that loads the datum in the frame at `from` and puts it in `into`.
		case load(DataType, into: Register, from: Frame.Location)
		
		/// An effect that retrieves the datum from `from` and stores it in the frame at `into`.
		case store(DataType, into: Frame.Location, from: Register)
		
		/// An effect that allocates a buffer of `bytes` bytes and puts a capability for that buffer in given register.
		///
		/// If `onFrame` is `true` and a contiguous call stack is used, the buffer is allocated in the current call frame and automatically deallocated when the frame is popped, after which it must not be accessed; otherwise, the buffer is allocated on the heap.
		case createBuffer(bytes: Source, capability: Register, onFrame: Bool)
		
		/// An effect that deallocates the buffer referred by the capability in given register.
		///
		/// This effect must only be used with buffers allocated in the current call frame. For any two buffers *a* and *b* allocated in the current call frame, *b* must be deallocated exactly once before deallocating *a*. Deallocation is not required before popping the call frame; in that case, deallocation is automatic. This effect does nothing if the contiguous call stack is disabled.
		case destroyBuffer(capability: Register)
		
		/// An effect that loads the datum at byte offset `offset` in the buffer at `buffer` and puts it in `into`.
		case loadElement(DataType, into: Register, buffer: Register, offset: Register)
		
		/// An effect that retrieves the datum from `from` and stores it at byte offset `offset` in the buffer at `buffer`.
		case storeElement(DataType, buffer: Register, offset: Register, from: Register)
		
		/// An effect that derives a capability to given label and puts it in given register.
		case deriveCapability(in: Register, to: Label)
		
		/// An effect that pushes given frame to the call stack.
		///
		/// This effect's semantics depend on the currently active calling convention:
		/// * If GCCC is used, this effect pushes `cfp` to it, copies `csp` to `cfp`, and offsets `csp` *b* bytes downward, where *b* is the byte size allocated by the frame.
		/// * If GHSCC is used, this effect allocates a call frame of *b* bytes on the heap, stores the previous frame capability (as sealed by the scall routine in `cfp`) on it, and puts a capability to the call frame in `cfp`.
		///
		/// This effect must be executed exactly once before any effects accessing the call frame.
		case pushFrame(Frame)
		
		/// An effect that pops a frame from the call stack.
		///
		/// This effect's semantics depend on the currently active calling convention:
		/// * If GCCC is used, this effect copies `cfp` to `csp` and pops `cfp` from the stack.
		/// * If GHSCC is used, this effect loads the previous (still sealed) frame capability into `cfp`.
		///
		/// This effect must be executed exactly once before any effects accessing the previous call frame. If GHSCC is used, an additional return is required before the previous call frame is available.
		case popFrame
		
		/// An effect that derives a capability from `source`, keeping at most the specified permissions, and puts it in `source`.
		///
		/// The capability in `destination` contains a permission *p* iff *p* is in the capability in `source` **and** if *p* is among the specified permissions.
		///
		/// A hardware exception is raised if `source` doesn't contain a valid, unsealed capability.
		case permit([Permission], destination: Register, source: Register)
		
		/// An effect that clears all registers except the structural registers `csp`, `cgp`, `ctp`, and `cfp` as well as given registers.
		///
		/// When using a secure calling convention, this effect must be executed before jumping to untrusted or partially untrusted code to ensure that the target code does not get unintended authority. Any registers, whether containing non-capability data or capabilities with intended authority, can be exempted from clearing.
		///
		/// `ctp` and `cgp` are reserved global registers whereas `csp` and `cfp` are managed by the runtime. These registers therefore cannot explicitly be cleared in MM.
		case clearAll(except: [Register])
		
		/// An effect that jumps to `to` if *x* *R* *y*, where *x* and *y* are given registers and *R* is given relation.
		case branch(to: Label, Register, BranchRelation, Register)
		
		/// An effect that jumps to given target.
		///
		/// If the target is a sentry capability, it is unsealed first.
		///
		/// A hardware exception is raised if `target` doesn't contain a valid capability that permits execution or if the capability is sealed (except as a sentry).
		case jump(to: Target)
		
		/// An effect that links the return capability and calls the procedure with given name.
		///
		/// Depending on the calling convention, this effect either jumps to the target or performs a scall.
		case call(Label)
		
		/// An effect that returns control to the caller.
		///
		/// If scall invocations are used, this effect invokes the code capability `cra` with the data capability `cfp` thereby unsealing both for the caller. Otherwise, this effect jumps to the address in `cra`, unsealing it first if it is a sentry capability.
		case `return`
		
		/// An effect that can jumped to using given label.
		indirect case labelled(Label, Effect)
		
		/// An effect that does nothing.
		static var nop: Self { .compute(destination: .zero, .zero, .add, .register(.zero)) }
		
		// See protocol.
		@ArrayBuilder<Lower.Statement>
		func lowered(in context: inout Context) throws -> [Lower.Statement] {
			let temp = Lower.Register.t0
			switch self {
				
				case .copy(let dataType, into: let destination, from: let source):
				try Lower.Effect.copy(dataType, into: destination.lowered(), from: source.lowered())
				
				case .compute(let destination, let lhs, let operation, let rhs):
				try Lower.Effect.compute(destination: destination.lowered(), lhs.lowered(), operation, rhs.lowered())
				
				case .load(let dataType, into: let destination, from: let source):
				Lower.Effect.offsetCapability(destination: temp, source: .fp, offset: .constant(source.offset))
				Lower.Effect.load(dataType, destination: try destination.lowered(), address: temp)
				
				case .store(let dataType, into: let destination, from: let source):
				Lower.Effect.offsetCapability(destination: temp, source: .fp, offset: .constant(destination.offset))
				Lower.Effect.store(dataType, address: temp, source: try source.lowered())
				
				case .createBuffer(bytes: let bytes, capability: let destinationBuffer, onFrame: false):
				let lengthReg = Lower.Register.t0	// cf. alloc routine
				let bufferReg = Lower.Register.t0	// cf. alloc routine
				let allocCapReg = Lower.Register.t1
				let destinationBufferReg = try destinationBuffer.lowered()
				Lower.Effect.compute(destination: lengthReg, .zero, .add, try bytes.lowered())
				Lower.Effect.callRuntimeRoutine(.allocationRoutineCapability, using: allocCapReg)
				if bufferReg != destinationBufferReg {
					Lower.Effect.copy(.cap, into: destinationBufferReg, from: bufferReg)
				}
				
				case .createBuffer(bytes: let bytes, capability: let buffer, onFrame: true):
				if context.configuration.callingConvention.usesContiguousCallStack {
					
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
					switch bytes {
						
						case .constant(let bytes):
						Lower.Effect.offsetCapability(destination: buffer, source: .sp, offset: .constant(-bytes))
						
						case .register(let bytesReg):
						Lower.Effect.compute(destination: temp, .zero, .sub, .register(try bytesReg.lowered()))
						Lower.Effect.offsetCapability(destination: buffer, source: .sp, offset: .register(temp))
						
					}
					
					// Restrict its bounds. Its base might move downwards, its length might increase.
					Lower.Effect.setCapabilityBounds(destination: buffer, base: buffer, length: try bytes.lowered())
					
					// Move stack capability over the allocated region.
					Lower.Effect.getCapabilityAddress(destination: temp, source: buffer)
					Lower.Effect.setCapabilityAddress(destination: .sp, source: .sp, address: temp)
					
				} else {
					try Self.createBuffer(bytes: bytes, capability: buffer, onFrame: false).lowered(in: &context)
				}
				
				case .destroyBuffer(let buffer):
				if context.configuration.callingConvention.usesContiguousCallStack {
					Lower.Effect.getCapabilityLength(destination: temp, source: try buffer.lowered())
					Lower.Effect.offsetCapability(destination: .sp, source: .sp, offset: .register(temp))
				}
				
				case .loadElement(let dataType, into: let destination, buffer: let buffer, offset: let offset):
				try Lower.Effect.offsetCapability(destination: destination.lowered(), source: buffer.lowered(), offset: .register(offset.lowered()))
				try Lower.Effect.load(dataType, destination: destination.lowered(), address: destination.lowered())
				
				case .storeElement(let dataType, buffer: let buffer, offset: let offset, from: let source):
				try Lower.Effect.offsetCapability(destination: temp, source: buffer.lowered(), offset: .register(offset.lowered()))
				try Lower.Effect.store(dataType, address: temp, source: source.lowered())
				
				case .deriveCapability(in: let destination, to: let label):
				Lower.Effect.deriveCapabilityFromLabel(destination: try destination.lowered(), label: label)
				
				case .pushFrame(let frame):
				switch context.configuration.callingConvention {
					
					case .conventional:
					do {
						
						// Save previous fp — defer updating sp since fp is already included in the allocated byte size.
						Lower.Effect.offsetCapability(destination: temp, source: .sp, offset: .constant(-DataType.cap.byteSize))
						Lower.Effect.store(.cap, address: temp, source: .fp)
						
						// Set up fp for new frame — using deferred sp.
						Lower.Effect.copy(.cap, into: .fp, from: temp)
						
						// Allocate space for frame by pushing sp downward.
						Lower.Effect.offsetCapability(destination: .sp, source: .sp, offset: .constant(-frame.allocatedByteSize))
						
					}
					
					case .heap:
					do {
						
						// Allocate frame on heap.
						let lengthReg = Lower.Register.t0	// cf. alloc routine
						let bufferReg = Lower.Register.t0	// cf. alloc routine
						let allocCapReg = Lower.Register.t1
						Lower.Effect.compute(destination: lengthReg, .zero, .add, .constant(frame.allocatedByteSize))
						Lower.Effect.callRuntimeRoutine(.allocationRoutineCapability, using: allocCapReg)
						
						// Save previous fp in offset 0 of newly allocated frame.
						Lower.Effect.store(.cap, address: bufferReg, source: .fp)
						
						// Update cfp.
						Lower.Effect.copy(.cap, into: .fp, from: bufferReg)
						
					}
					
				}
				
				case .popFrame:
				switch context.configuration.callingConvention {
					
					case .conventional:
					do {
						
						// Pop frame and saved fp by moving sp one word above the saved fp's location.
						Lower.Effect.offsetCapability(destination: .sp, source: .fp, offset: .constant(+DataType.cap.byteSize))
						
						// Restore saved fp — follow the linked list.
						Lower.Effect.load(.cap, destination: .fp, address: .fp)
						
					}
					
					case .heap:
					Lower.Effect.copy(.cap, into: .fp, from: .invocationData)
					
				}
				
				case .permit(let permissions, destination: let destination, source: let source):
				try Lower.Effect.permit(permissions, destination: destination.lowered(), source: source.lowered(), using: temp)
				
				case .clearAll(except: let sparedRegisters):
				let sparedRegisters = Set(try sparedRegisters.lowered()).union([.sp, .gp, .tp, .fp])
				let clearedRegisters = Lower.Register.allCases.filter { !sparedRegisters.contains($0) }
				Lower.Effect.clear(clearedRegisters)
				
				case .branch(to: let target, let rs1, let relation, let rs2):
				try Lower.Effect.branch(to: target, rs1.lowered(), relation, rs2.lowered())
				
				case .jump(to: let target):
				Lower.Effect.jump(to: try target.lowered(), link: .zero)
				
				case .call(let name):
				switch context.configuration.callingConvention {
					
					case .conventional:
					Lower.Effect.jump(to: .label(name), link: .ra)
						
					case .heap:
					Lower.Effect.deriveCapabilityFromLabel(destination: .invocationData, label: name)
					Lower.Effect.callRuntimeRoutine(.secureCallingRoutineCapability, using: temp)	// also links cra
					Lower.Effect.copy(.cap, into: .fp, from: .invocationData)	// restore fp
					
				}
				
				case .return:
				switch context.configuration.callingConvention {
					case .conventional:	Lower.Effect.return
					case .heap:			Lower.Effect.invoke(target: .ra, data: .fp)
				}
				
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
	///
	/// The allocation routine takes a length in `t0` and returns a buffer capability in `ct0`. The routine may also touch `ct1` and `ct2` but will not leak any unintended new authority.
	static var allocationRoutineCapability: Self { "mm.alloc.cap" }
	
	/// The label for the capability to the secure calling (scall) routine.
	///
	/// The scall routine takes a target capability in `invocationData`, a return capability in `cra`, a frame capability in `cfp`, and function arguments in argument registers. It returns the same frame capability in `invocationData` and any function results in argument registers.
	///
	/// The routine may touch any register but will not leak any unintended new authority. Procedures are expected to perform appropriate clearing of registers not used for arguments or for the scall itself before invoking the scall routine or before returning to the callee.
	///
	/// The callee receives a sealed return–frame capability pair in `cra` and `cfp` as well as function arguments in argument registers, and returns function results in argument registers. It can return to the caller by invoking the return–frame capability pair.
	static var secureCallingRoutineCapability: Self { "mm.scall.cap" }
	
}
