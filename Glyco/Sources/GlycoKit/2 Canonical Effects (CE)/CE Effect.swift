// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension CE {
	
	/// A CE effect.
	public enum Effect : Codable, Equatable, MultiplyLowerable {
		
		/// An effect that copies the contents from `from` to `into`.
		case copy(DataType, into: Register, from: Register)
		
		/// An effect that performs *x* `operation` *y* where *x* is the value in the second given register and *y* is the value from given source, and puts in `destination`.
		case compute(destination: Register, Register, BinaryOperator, Source)
		
		/// An effect that loads the datum at `address` and puts it in `destination`.
		case load(DataType, destination: Register, address: Register)
		
		/// An effect that retrieves the datum from `source` and stores it at `address`.
		case store(DataType, address: Register, source: Register)
		
		/// An effect that derives a capability from PCC to the memory location labelled `label` and puts it in `destination`.
		case deriveCapabilityFromLabel(destination: Register, label: Label)
		
		/// An effect that offsets the capability in `source` by the offset in `offset` and puts it in `destination`.
		case offsetCapability(destination: Register, source: Register, offset: Source)
		
		/// An effect that determines the (integer) length of the capability in `source` and puts it in `destination`.
		case getCapabilityLength(destination: Register, source: Register)
		
		/// An effect that copies the capability from `source` to `destination` then adjusts its length to the length in `length`.
		///
		/// If the bounds cannot be represented exactly, the base may be adjusted downwards and the length upwards. A hardware exception is raised if the adjusted bounds exceed the bounds of the source capability.
		case setCapabilityBounds(destination: Register, source: Register, length: Source)
		
		/// An effect that determines the (integer) address of the capability in `source` and puts it in `destination`.
		case getCapabilityAddress(destination: Register, source: Register)
		
		/// An effect that copies copies `destination` to `source`, replacing the address with the integer in `address`.
		case setCapabilityAddress(destination: Register, source: Register, address: Register)
		
		/// An effect that subtracts the address in `cs2` from the address in `cs1` and puts the difference in `destination`.
		case getCapabilityDistance(destination: Register, cs1: Register, cs2: Register)
		
		/// An effect that seals the capability in `source` using the address of the capability in `seal` as the object type and puts it in `destination`.
		///
		/// A hardware exception is raised if `source` or `seal` don't contain valid, unsealed capabilities, or if `seal` contains a capability that doesn't permit sealing, points outside its bounds, or whose address isn't a valid object type.
		case seal(destination: Register, source: Register, seal: Register)
		
		/// An effect that seals the capability in `source` as a sentry and puts it in `destination`.
		///
		/// A hardware exception is raised if `source` doesn't contain a valid, unsealed capability that permits execution.
		case sealEntry(destination: Register, source: Register)
		
		/// An effect that derives a capability from `source`, keeping at most the specified permissions, and puts it in `source`.
		///
		/// The capability in `destination` contains a permission *p* iff *p* is in the capability in `source` **and** if *p* is among the specified permissions.
		///
		/// The effect uses `using` to keep the permissions bitmask. It must be different from `source`.
		///
		/// A hardware exception is raised if `source` doesn't contain a valid, unsealed capability.
		case permit([Permission], destination: Register, source: Register, using: Register)
		
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
		
		/// An effect that jumps to the address in `target` after unsealing it, and puts the datum in `data` in `ct6` after unsealing it.
		///
		/// A hardware exception is raised
		/// * if `target` or `data` don't contain valid capabilities with the same object type that permit invocation,
		/// * if `target` contains a capability that doesn't permit execution,
		/// * if `data` contains a capability that permits execution, or
		/// * if `target` contains a capability that points outside its bounds.
		case invoke(target: Register, data: Register)
		
		/// An effect that jumps to address *x*, where *x* is the value in `cra`.
		case `return`
		
		/// An effect that can jumped to using given label.
		indirect case labelled(Label, Effect)
		
		/// A placeholder for a buffer containing `count` elements of given data type.
		case buffer(DataType, count: Int)
		
		/// An effect that does nothing.
		static var nop: Self { .compute(destination: .zero, .zero, .add, .register(.zero)) }
		
		// See protocol.
		@ArrayBuilder<Lower.Statement>
		func lowered(in context: inout ()) throws -> [Lower.Statement] {
			switch self {
				
				case .copy(.u8, into: let destination, from: let source),	// TODO: Copy u8 as s32 then mask out upper bits.
					.copy(.s32, into: let destination, from: let source):
				Lower.Instruction.copyWord(destination: destination, source: source)
				
				case .copy(.cap, into: let destination, from: let source):
				Lower.Instruction.copyCapability(destination: destination, source: source)
				
				case .compute(let destination, let rs1, let operation, .register(let rs2)):
				Lower.Instruction.computeWithRegister(operation: operation, rd: destination, rs1: rs1, rs2: rs2)
				
				case .compute(let destination, let rs1, let operation, .constant(let imm)):
				Lower.Instruction.computeWithImmediate(operation: operation, rd: destination, rs1: rs1, imm: imm)
				
				case .load(.u8, destination: let destination, address: let address):
				Lower.Instruction.loadByte(destination: destination, address: address)
				
				case .load(.s32, destination: let destination, address: let address):
				Lower.Instruction.loadSignedWord(destination: destination, address: address)
				
				case .load(.cap, destination: let destination, address: let address):
				Lower.Instruction.loadCapability(destination: destination, address: address)
				
				case .store(.u8, address: let address, source: let source):
				Lower.Instruction.storeByte(source: source, address: address)
				
				case .store(.s32, address: let address, source: let source):
				Lower.Instruction.storeSignedWord(source: source, address: address)
				
				case .store(.cap, address: let address, source: let source):
				Lower.Instruction.storeCapability(source: source, address: address)
				
				case .deriveCapabilityFromLabel(destination: let destination, label: let label):
				Lower.Instruction.deriveCapabilityFromLabel(destination: destination, label: label)
				
				case .offsetCapability(destination: let destination, source: let source, offset: .register(let offset)):
				Lower.Instruction.offsetCapability(destination: destination, source: source, offset: offset)
				
				case .offsetCapability(destination: let destination, source: let source, offset: .constant(let offset)):
				Lower.Instruction.offsetCapabilityWithImmediate(destination: destination, source: source, offset: offset)
				
				case .getCapabilityLength(destination: let destination, source: let source):
				Lower.Instruction.getCapabilityLength(destination: destination, source: source)
				
				case .setCapabilityBounds(destination: let destination, source: let source, length: .register(let length)):
				Lower.Instruction.setCapabilityBounds(destination: destination, source: source, length: length)
				
				case .setCapabilityBounds(destination: let destination, source: let source, length: .constant(let length)):
				Lower.Instruction.setCapabilityBoundsWithImmediate(destination: destination, source: source, length: length)
				
				case .getCapabilityAddress(destination: let destination, source: let source):
				Lower.Instruction.getCapabilityAddress(destination: destination, source: source)
				
				case .setCapabilityAddress(destination: let destination, source: let source, address: let address):
				Lower.Instruction.setCapabilityAddress(destination: destination, source: source, address: address)
				
				case .getCapabilityDistance(destination: let destination, cs1: let cs1, cs2: let cs2):
				Lower.Instruction.getCapabilityDistance(destination: destination, cs1: cs1, cs2: cs2)
				
				case .seal(destination: let destination, source: let source, seal: let seal):
				Lower.Instruction.seal(destination: destination, source: source, seal: seal)
				
				case .sealEntry(destination: let destination, source: let source):
				Lower.Instruction.sealEntry(destination: destination, source: source)
				
				case .permit(_, destination: _, source: let source, using: let permissionsRegister) where source == permissionsRegister:
				throw LoweringError.sourceAndPermissionsRegisterEqual(source)
				
				case .permit(let permissions, destination: let destination, source: let source, using: let permissionsRegister):
				Lower.Instruction.computeWithImmediate(operation: .add, rd: permissionsRegister, rs1: .zero, imm: Int(permissions.bitmask))
				Lower.Instruction.permit(destination: destination, source: source, mask: permissionsRegister)
				
				case .clear(let registers):
				let registersByQuarter = Dictionary(grouping: registers, by: { $0.ordinal / 8 })
				let masksByQuarter = registersByQuarter.mapValues { registers -> UInt8 in
					registers
						.lazy
						.map { 1 << ($0.ordinal % 8) }
						.reduce(0, |)
				}
				for (quarter, mask) in masksByQuarter where mask != 0 {
					Lower.Instruction.clear(quarter: quarter, mask: mask)
				}
				
				case .branch(to: let target, let rs1, let relation, let rs2):
				Lower.Instruction.branch(rs1: rs1, relation: relation, rs2: rs2, target: target)
				
				case .jump(.label(let target), link: let link):
				Lower.Instruction.jump(target: target, link: link)
				
				case .jump(.register(let target), link: let link):
				Lower.Instruction.jumpWithRegister(target: target, link: link)
				
				case .invoke(target: let target, data: let data):
				Lower.Instruction.invoke(target: target, data: data)
				
				case .return:
				Lower.Instruction.jumpWithRegister(target: .ra, link: .zero)
				
				case .labelled(let label, let effect):
				if let (first, tail) = try effect.lowered(in: &context).splittingFirst() {
					Lower.Statement.labelled(label, first)
					tail
				}
				
				case .buffer(.s32, count: 1):
				Lower.Statement.signedWord(0)
				
				case .buffer(.cap, count: 1):
				Lower.Statement.nullCapability
				
				case .buffer(let dataType, count: let count):
				Lower.Statement.filled(value: 0, datumByteSize: dataType.byteSize, copies: count)
				
			}
		}
		
		enum LoweringError : LocalizedError {
			
			/// An error indicating that a `permit` effect has the same source and `using` register.
			case sourceAndPermissionsRegisterEqual(Register)
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					case .sourceAndPermissionsRegisterEqual(let register):
					return "A permit effect has the same source and `using` register \(register)."
				}
			}
			
		}
		
	}
	
}

func ~ (label: CE.Label, effect: CE.Effect) -> CE.Effect {
	.labelled(label, effect)
}
