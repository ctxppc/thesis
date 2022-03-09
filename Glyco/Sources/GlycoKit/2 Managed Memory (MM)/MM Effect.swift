// Glyco © 2021–2022 Constantino Tsarouhas

extension MM {
	
	/// An MM effect.
	public enum Effect : Codable, Equatable, MultiplyLowerable {
		
		/// An effect that copies the contents from `from` to `into`.
		case copy(DataType, into: Register, from: Register)
		
		/// An effect that performs *x* `operation` *y* where *x* is the value in the second given register and *y* is the value from given source, and puts in `destination`.
		case compute(destination: Register, Register, BinaryOperator, Source)
		
		static func load(into destination: Register, value: Int) -> Self { .compute(destination: destination, .zero, .add, .constant(value)) }
		
		/// An effect that loads the datum in the frame at `from` and puts it in `into`.
		case load(DataType, into: Register, from: Frame.Location)
		
		/// An effect that retrieves the datum from `from` and stores it in the frame at `into`.
		case store(DataType, into: Frame.Location, from: Register)
		
		/// An effect that allocates a buffer of `bytes` bytes and puts a capability for that buffer in given register.
		///
		/// If `onFrame` is `true` and the call stack is enabled, the buffer is allocated on the call frame and automatically deallocated when the frame is popped, after which it must not be accessed.
		case createBuffer(bytes: Source, capability: Register, onFrame: Bool)
		
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
		
		/// An effect that puts the next PCC in `link`, then jumps to given target.
		///
		/// If the target is a sentry capability, it is unsealed first.
		///
		/// A hardware exception is raised if `target` doesn't contain a valid capability that permits execution or if the capability is sealed (except as a sentry).
		case jump(to: Target, link: Register)
		
		/// Returns an effect that puts the next PCC in `cra`, then jumps to given target.
		static func call(_ target: Label) -> Self { .jump(to: .label(target), link: .ra) }
		
		/// An effect that jumps to address *x*, where *x* is the value in `cra`.
		case `return`
		
		/// An effect that can jumped to using given label.
		indirect case labelled(Label, Effect)
		
		/// An effect that does nothing.
		static var nop: Self { .compute(destination: .zero, .zero, .add, .register(.zero)) }
		
		// See protocol.
		@ArrayBuilder<Lower.Effect>
		func lowered(in context: inout Context) throws -> [Lower.Effect] {
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
				
				case .createBuffer(bytes: let bytes, capability: let buffer, onFrame: false):
				Lower.Effect.compute(destination: .t0, .zero, .add, try bytes.lowered())
				Lower.Effect.deriveCapabilityFromLabel(destination: .t1, label: .allocationRoutineCapability)
				Lower.Effect.jump(to: .register(.t1), link: .ra)
				Lower.Effect.copy(.cap, into: try buffer.lowered(), from: .t0)
				
				case .createBuffer(bytes: let bytes, capability: let buffer, onFrame: true):
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
					switch bytes {
						
						case .constant(let bytes):
						Lower.Effect.offsetCapability(destination: buffer, source: .sp, offset: .constant(-bytes))
						
						case .register(let bytesReg):
						Lower.Effect.compute(destination: temp, .zero, .sub, .register(try bytesReg.lowered()))
						Lower.Effect.offsetCapability(destination: buffer, source: .sp, offset: .register(temp))
						
					}
					
					// Restrict its bounds. Its base might move downwards, its length might increase.
					Lower.Effect.setCapabilityBounds(destination: buffer, source: buffer, length: try bytes.lowered())
					
					// Move stack capability over the allocated region.
					Lower.Effect.getCapabilityAddress(destination: temp, source: buffer)
					Lower.Effect.setCapabilityAddress(destination: .sp, source: .sp, address: temp)
					
				} else {
					try Self.createBuffer(bytes: bytes, capability: buffer, onFrame: false).lowered(in: &context)
				}
				
				case .destroyBuffer(let buffer):
				if context.configuration.callingConvention.callStackEnabled {
					Lower.Effect.getCapabilityLength(destination: temp, source: try buffer.lowered())
					Lower.Effect.offsetCapability(destination: .sp, source: .sp, offset: .register(temp))
				}
				
				case .loadElement(let dataType, into: let destination, buffer: let buffer, offset: let offset):
				try Lower.Effect.offsetCapability(destination: destination.lowered(), source: buffer.lowered(), offset: .register(offset.lowered()))
				try Lower.Effect.load(dataType, destination: destination.lowered(), address: destination.lowered())
				
				case .storeElement(let dataType, buffer: let buffer, offset: let offset, from: let source):
				try Lower.Effect.offsetCapability(destination: temp, source: buffer.lowered(), offset: .register(offset.lowered()))
				try Lower.Effect.store(dataType, address: temp, source: source.lowered())
				
				case .pushFrame(let frame):
				do {
					
					// Save previous fp — defer updating sp since fp is already included in the allocated byte size.
					Lower.Effect.offsetCapability(destination: temp, source: .sp, offset: .constant(-DataType.cap.byteSize))
					Lower.Effect.store(.cap, address: temp, source: .fp)
					
					// Set up fp for new frame — using deferred sp.
					Lower.Effect.copy(.cap, into: .fp, from: temp)
					
					// Allocate space for frame by pushing sp downward.
					Lower.Effect.offsetCapability(destination: .sp, source: .sp, offset: .constant(-frame.allocatedByteSize))
					
				}
				
				case .popFrame:
				do {
					
					// Pop frame and saved fp by moving sp one word above the saved fp's location.
					Lower.Effect.offsetCapability(destination: .sp, source: .fp, offset: .constant(+DataType.cap.byteSize))
					
					// Restore saved fp — follow the linked list.
					Lower.Effect.load(.cap, destination: .fp, address: .fp)
					
				}
				
				case .permit(let permissions, destination: let destination, source: let source):
				try Lower.Effect.permit(permissions, destination: destination.lowered(), source: source.lowered(), using: temp)
				
				case .clear(let registers):
				Lower.Effect.clear(try registers.lowered())
				
				case .branch(to: let target, let rs1, let relation, let rs2):
				try Lower.Effect.branch(to: target, rs1.lowered(), relation, rs2.lowered())
				
				case .jump(to: let target, link: let link):
				try Lower.Effect.jump(to: target.lowered(), link: link.lowered())
				
				case .return:
				Lower.Effect.return
				
				case .labelled(let label, let effect):
				if let (first, tail) = try effect.lowered(in: &context).splittingFirst() {
					Lower.Effect.labelled(label, first)
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
