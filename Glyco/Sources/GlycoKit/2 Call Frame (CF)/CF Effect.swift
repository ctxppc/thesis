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
		
		/// An effect that pushes a vector of `count` elements of given data type to the call frame and puts a capability for that vector in given location.
		case allocateVector(DataType, count: Int = 1, into: Register)
		
		/// An effect that loads the element of the vector at `vector` at the zero-based position in `index` and puts it in `into`.
		case loadElement(DataType, into: Register, vector: Register, index: Register)
		
		/// An effect that retrieves the datum from `from` and stores it as an element of the vector at `vector` at the zero-based position in `index`.
		case storeElement(DataType, vector: Register, index: Register, from: Register)
		
		/// An effect that retrieves the value from given register and pushes it to the call frame.
		case push(DataType, Register)
		
		/// An effect that removes `bytes` bytes from the stack.
		case pop(bytes: Int)
		
		/// Pushes a frame of size `bytes` bytes to the call stack by pushing `cfp` to the stack, copying `csp` to `cfp`, and offsetting `csp` by `bytes` bytes downward.
		///
		/// This effect must be executed exactly once before any effects accessing the call frame.
		case pushFrame(bytes: Int)
		
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
		func lowered(in context: inout Frame) throws -> [Lower.Instruction] {
			let temp = Lower.Register.t0
			switch self {
				
				case .copy(.byte, into: let destination, from: let source),	// TODO: Copy byte as word then mask out upper bits.
					.copy(.signedWord, into: let destination, from: let source):
				return try [.copyWord(destination: destination.lowered(), source: source.lowered())]
				
				case .copy(.capability, into: let destination, from: let source):
				return try [.copyCapability(destination: destination.lowered(), source: source.lowered())]
				
				case .compute(into: let destination, value: .registerRegister(let rs1, let operation, let rs2)):
				return try [.registerRegister(operation: operation, rd: destination.lowered(), rs1: rs1.lowered(), rs2: rs2.lowered())]
				
				case .compute(into: let destination, value: .registerImmediate(let rs1, let operation, let imm)):
				return try [.registerImmediate(operation: operation, rd: destination.lowered(), rs1: rs1.lowered(), imm: imm)]
				
				case .load(.byte, into: let destination, from: let source):
				return [
					.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: source.offset),
					.loadByte(destination: try destination.lowered(), address: temp)
				]
				
				case .load(.signedWord, into: let destination, from: let source):
				return [
					.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: source.offset),
					.loadSignedWord(destination: try destination.lowered(), address: temp)
				]
				
				case .load(.capability, into: let destination, from: let source):
				return [.loadCapability(destination: try destination.lowered(), address: .fp, offset: source.offset)]
				
				case .store(.byte, into: let destination, from: let source):
				return [
					.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: destination.offset),
					.storeByte(source: try source.lowered(), address: temp)
				]
				
				case .store(.signedWord, into: let destination, from: let source):
				return [
					.offsetCapabilityWithImmediate(destination: temp, source: .fp, offset: destination.offset),
					.storeSignedWord(source: try source.lowered(), address: temp)
				]
				
				case .store(.capability, into: let destination, from: let source):
				return [.storeCapability(source: try source.lowered(), address: temp, offset: destination.offset)]
				
				case .allocateVector(let dataType, count: let count, into: let vector):
				/*
					 ┌──────────┐ high
					 │          │
					 │          │◄───── previous sp
					 │ ┌──────┐ │
					 │ │ …    │ │
					 │ │ 3    │ │
					 │ │ 2    │ │
					 │ │ 1    │ │
					 │ │ 0    │ │◄───── vector & new sp
					 │ └──────┘ │
					 │          │
					 └──────────┘ low
				 */
				let vector = try vector.lowered()
				let byteSize = dataType.byteSize * count
				return [
					.offsetCapabilityWithImmediate(destination: vector, source: .sp, offset: -byteSize),	// compute tentative base
					.setCapabilityBounds(destination: vector, source: vector, length: byteSize),			// actual base may be lower, length may be greater
					.getCapabilityAddress(destination: temp, source: vector),								// move stack pointer to actual base
					.setCapabilityAddress(destination: .sp, source: .sp, address: .t0),
				]
				
				case .loadElement(.byte, into: let destination, vector: let vector, index: let index):
				return try [
					.offsetCapability(destination: destination.lowered(), source: vector.lowered(), offset: index.lowered()),
					.loadByte(destination: destination.lowered(), address: destination.lowered()),
				]
				
				case .loadElement(.signedWord, into: let destination, vector: let vector, index: let index):
				return try [
					.offsetCapability(destination: destination.lowered(), source: vector.lowered(), offset: index.lowered()),
					.loadSignedWord(destination: destination.lowered(), address: destination.lowered()),
				]
				
				case .loadElement(.capability, into: let destination, vector: let vector, index: let index):
				return try [
					.offsetCapability(destination: destination.lowered(), source: vector.lowered(), offset: index.lowered()),
					.loadCapability(destination: destination.lowered(), address: destination.lowered(), offset: 0),
				]
				
				case .storeElement(.byte, vector: let vector, index: let index, from: let source):
				return try [
					.offsetCapability(destination: temp, source: vector.lowered(), offset: index.lowered()),
					.storeByte(source: source.lowered(), address: temp),
				]
				
				case .storeElement(.signedWord, vector: let vector, index: let index, from: let source):
				return try [
					.offsetCapability(destination: temp, source: vector.lowered(), offset: index.lowered()),
					.storeSignedWord(source: source.lowered(), address: temp),
				]
				
				case .storeElement(.capability, vector: let vector, index: let index, from: let source):
				return try [
					.offsetCapability(destination: temp, source: vector.lowered(), offset: index.lowered()),
					.storeCapability(source: source.lowered(), address: temp, offset: 0),
				]
				
				case .push(.capability, let source):
				return try [
					.offsetCapabilityWithImmediate(destination: .sp, source: .sp, offset: -DataType.capability.byteSize),
					.storeCapability(source: source.lowered(), address: .sp, offset: 0),
				]
				
				case .push(let type, let source):
				return try [
					.offsetCapabilityWithImmediate(destination: .sp, source: .sp, offset: -type.byteSize),
					.storeByte(source: source.lowered(), address: .sp),
				]
				
				case .pop(bytes: let bytes):
				return [.offsetCapabilityWithImmediate(destination: .sp, source: .sp, offset: bytes)]
				
				case .pushFrame(bytes: let bytes):
				let frameCapOffsetBeforeStackCapUpdate = -DataType.capability.byteSize
				return [
					
					// Push fp but defer sp update.
					.storeCapability(source: .fp, address: .sp, offset: frameCapOffsetBeforeStackCapUpdate),
					
					// Set up fp for new frame using virtually updated sp.
					.offsetCapabilityWithImmediate(destination: .fp, source: .sp, offset: frameCapOffsetBeforeStackCapUpdate),
					
					// Actually update sp, for both saved fp and requested frame size.
					.offsetCapabilityWithImmediate(destination: .sp, source: .sp, offset: -(DataType.capability.byteSize + bytes)),
					
				]

				case .popFrame:
				return [
					
					// Pop frame and saved fp by moving sp one word above the saved fp's location.
					.offsetCapabilityWithImmediate(destination: .sp, source: .fp, offset: +DataType.capability.byteSize),
					
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
