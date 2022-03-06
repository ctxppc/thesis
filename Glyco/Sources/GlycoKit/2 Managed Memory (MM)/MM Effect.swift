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
		/// If `onFrame` is `true`, the buffer is allocated on the call frame and automatically deallocated when the frame is popped, after which it must not be accessed.
		case createBuffer(bytes: Int, capability: Register, onFrame: Bool)
		
		/// An effect that deallocates the buffer referred by the capability in given register.
		///
		/// This effect must only be used with buffers allocated in the current call frame. For any two buffers *a* and *b* allocated in the current call frame, *b* must be deallocated exactly once before deallocating *a*. Deallocation is not required before popping the call frame; in that case, deallocation is automatic.
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
		func lowered(in context: inout ()) throws -> [Lower.Statement] {
			let temp = Lower.Register.t0
			switch self {
				
				case .copy(.u8, into: let destination, from: let source),	// TODO: Copy u8 as s32 then mask out upper bits.
					.copy(.s32, into: let destination, from: let source):
				return try [.instruction(.copyWord(destination: destination.lowered(), source: source.lowered()))]
				
				case .copy(.cap, into: let destination, from: let source):
				return try [.instruction(.copyCapability(destination: destination.lowered(), source: source.lowered()))]
				
				case .compute(let destination, .registerRegister(let rs1, let operation, let rs2)):
				return try [.instruction(.computeWithRegister(operation: operation, rd: destination.lowered(), rs1: rs1.lowered(), rs2: rs2.lowered()))]
				
				case .compute(let destination, .registerImmediate(let rs1, let operation, let imm)):
				return try [.instruction(.computeWithImmediate(operation: operation, rd: destination.lowered(), rs1: rs1.lowered(), imm: imm))]
				
				case .load(.u8, into: let destination, from: let source):
				return [
					.instruction(.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: source.offset)),
					.instruction(.loadByte(destination: try destination.lowered(), address: temp)),
				]
				
				case .load(.s32, into: let destination, from: let source):
				return [
					.instruction(.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: source.offset)),
					.instruction(.loadSignedWord(destination: try destination.lowered(), address: temp)),
				]
				
				case .load(.cap, into: let destination, from: let source):
				return [
					.instruction(.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: source.offset)),
					.instruction(.loadCapability(destination: try destination.lowered(), address: temp)),
				]
				
				case .store(.u8, into: let destination, from: let source):
				return [
					.instruction(.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: destination.offset)),
					.instruction(.storeByte(source: try source.lowered(), address: temp)),
				]
				
				case .store(.s32, into: let destination, from: let source):
				return [
					.instruction(.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: destination.offset)),
					.instruction(.storeSignedWord(source: try source.lowered(), address: temp)),
				]
				
				case .store(.cap, into: let destination, from: let source):
				return [
					.instruction(.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: destination.offset)),
					.instruction(.storeCapability(source: try source.lowered(), address: temp)),
				]
				
				case .createBuffer(bytes: let bytes, capability: let buffer, onFrame: false):
				let buffer = try buffer.lowered()
				return [
					
					// Derive buffer capability.
					.instruction(.setCapabilityBoundsWithImmediate(destination: buffer, source: .tp, length: bytes)),
					// FIXME: The base might move downward and into a previously allocated region.
					
					// Determine (possibly rounded-up) length of allocated buffer.
					.instruction(.getCapabilityLength(destination: temp, source: buffer)),
					
					// Move heap capability over the allocated region.
					.instruction(.offsetCapability(destination: .tp, source: .tp, offset: temp)),
					
				]
				
				case .createBuffer(bytes: let bytes, capability: let buffer, onFrame: true):
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
					
					// Derive buffer capability (without bounding it yet).
					.instruction(.offsetCapabilityWithImmediate(destination: buffer, source: .sp, offset: -bytes)),
					
					// Restrict its bounds. Its base might move downwards, its length might increase.
					.instruction(.setCapabilityBoundsWithImmediate(destination: buffer, source: buffer, length: bytes)),
					
					// Move stack capability over the allocated region.
					.instruction(.getCapabilityAddress(destination: temp, source: buffer)),
					.instruction(.setCapabilityAddress(destination: .sp, source: .sp, address: temp)),
					
				]
				
				case .destroyBuffer(let buffer):
				return [
					.instruction(.getCapabilityLength(destination: temp, source: try buffer.lowered())),
					.instruction(.offsetCapability(destination: .sp, source: .sp, offset: temp)),
				]
				
				case .loadElement(.u8, into: let destination, buffer: let buffer, offset: let offset):
				return try [
					.instruction(.offsetCapability(destination: destination.lowered(), source: buffer.lowered(), offset: offset.lowered())),
					.instruction(.loadByte(destination: destination.lowered(), address: destination.lowered())),
				]
				
				case .loadElement(.s32, into: let destination, buffer: let buffer, offset: let offset):
				return try [
					.instruction(.offsetCapability(destination: destination.lowered(), source: buffer.lowered(), offset: offset.lowered())),
					.instruction(.loadSignedWord(destination: destination.lowered(), address: destination.lowered())),
				]
				
				case .loadElement(.cap, into: let destination, buffer: let buffer, offset: let offset):
				return try [
					.instruction(.offsetCapability(destination: destination.lowered(), source: buffer.lowered(), offset: offset.lowered())),
					.instruction(.loadCapability(destination: destination.lowered(), address: destination.lowered())),
				]
				
				case .storeElement(.u8, buffer: let buffer, offset: let offset, from: let source):
				return try [
					.instruction(.offsetCapability(destination: temp, source: buffer.lowered(), offset: offset.lowered())),
					.instruction(.storeByte(source: source.lowered(), address: temp)),
				]
				
				case .storeElement(.s32, buffer: let buffer, offset: let offset, from: let source):
				return try [
					.instruction(.offsetCapability(destination: temp, source: buffer.lowered(), offset: offset.lowered())),
					.instruction(.storeSignedWord(source: source.lowered(), address: temp)),
				]
				
				case .storeElement(.cap, buffer: let buffer, offset: let offset, from: let source):
				return try [
					.instruction(.offsetCapability(destination: temp, source: buffer.lowered(), offset: offset.lowered())),
					.instruction(.storeCapability(source: source.lowered(), address: temp)),
				]
				
				case .pushFrame(let frame):
				return [
					
					// Save previous fp — defer updating sp since fp is already included in the allocated byte size.
					.instruction(.offsetCapabilityWithImmediate(destination: temp, source: .sp, offset: -DataType.cap.byteSize)),
					.instruction(.storeCapability(source: .fp, address: temp)),
					
					// Set up fp for new frame — using deferred sp.
					.instruction(.copyCapability(destination: .fp, source: temp)),
					
					// Allocate space for frame by pushing sp downward.
					.instruction(.offsetCapabilityWithImmediate(destination: .sp, source: .sp, offset: -frame.allocatedByteSize)),
					
				]

				case .popFrame:
				return [
					
					// Pop frame and saved fp by moving sp one word above the saved fp's location.
					.instruction(.offsetCapabilityWithImmediate(destination: .sp, source: .fp, offset: +DataType.cap.byteSize)),
					
					// Restore saved fp — follow the linked list.
					.instruction(.loadCapability(destination: .fp, address: .fp)),
					
				]
				
				case .permit(let permissions, destination: let destination, source: let source):
				let destination = try destination.lowered()
				return [
					.instruction(.computeWithImmediate(operation: .add, rd: destination, rs1: .zero, imm: Int(permissions.bitmask))),
					.instruction(.permit(destination: destination, source: try source.lowered(), mask: destination)),
				]
				
				case .clear(let registers):
				let registersByQuarter = Dictionary(grouping: registers, by: { $0.ordinal / 8 })
				let masksByQuarter = registersByQuarter.mapValues { registers -> UInt8 in
					registers
						.lazy
						.map { 1 << ($0.ordinal % 8) }
						.reduce(0, |)
				}
				return masksByQuarter.map { .instruction(.clear(quarter: $0.0, mask: $0.1)) }
				
				case .branch(to: let target, let rs1, let relation, let rs2):
				return try [.instruction(.branch(rs1: rs1.lowered(), relation: relation, rs2: rs2.lowered(), target: target))]
				
				case .jump(to: let target):
				return [.instruction(.jump(target: target))]
				
				case .call(let label):
				return [.instruction(.call(target: label))]
				
				case .return:
				return [.instruction(.return)]
				
				case .labelled(let label, let effect):
				guard let (first, tail) = try effect.lowered(in: &context).splittingFirst() else {
					return [] /* should never happen — famous last words */
				}
				return [.labelled(label, first)].appending(contentsOf: tail)
				
			}
		}
		
	}
	
}
