// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension RT {
	
	//sourcery: heavyGrammar
	/// An RT effect.
	public enum Effect : MultiplyLowerable, Element {
		
		/// An effect that copies the contents from `from` to `into`.
		case copy(DataType, into: Register, from: Register)
		
		/// An effect that performs *x* `operation` *y* where *x* is the value in the second given register and *y* is the value from given source, and puts in `destination`.
		///
		/// The source cannot be a constant if `operation` is  `.mul`.
		case compute(destination: Register, Register, BinaryOperator, Source)
		
		/// An effect that loads the datum at `address`, offset by `offset` bytes, and puts it in `destination`.
		///
		/// `offset` must be in the range [-2048; 2047].
		case load(DataType, destination: Register, address: Register, offset: Int)
		
		/// An effect that retrieves the datum from `source` and stores it at `address`, offset by `offset` bytes.
		///
		/// `offset` must be in the range [-2048; 2047].
		case store(DataType, address: Register, source: Register, offset: Int)
		
		/// An effect that derives a capability from PCC, adds `upperBits` to after left-shifting it by 12, and puts the resulting capability in `destination`.
		case deriveCapabilityFromPCC(destination: Register, upperBits: UInt)
		
		/// An effect that derives a capability from PCC to the memory location labelled `label` and puts it in `destination`.
		case deriveCapabilityFromLabel(destination: Register, label: Label)
		
		/// An effect that offsets the capability in `source` by the offset in `offset` and puts it in `destination`.
		case offsetCapability(destination: Register, source: Register, offset: Source)
		
		/// An effect that determines the (integer) length of the capability in `source` and puts it in `destination`.
		case getCapabilityLength(destination: Register, source: Register)
		
		/// An effect that copies the capability from `base` to `destination`, sets its base to the address of `base`, and adjusts its length to `length`.
		///
		/// If the bounds cannot be represented exactly, the base may be adjusted downwards and the length upwards. A hardware exception is raised if the adjusted bounds exceed the bounds of the source capability.
		case setCapabilityBounds(destination: Register, base: Register, length: Source)
		
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
		case invoke(target: Register, data: Register)
		
		/// An effect that puts the next PCC in `link` then jumps to the runtime routine with given labelled capability.
		///
		/// `link` is also used to prepare the target capability and therefore must not be `.zero`. The calling convention is dictated by the routine.
		case callRuntimeRoutine(capability: Label, link: Register)
		
		/// An effect that does nothing.
		static var nop: Self { .compute(destination: .zero, .zero, .add, .register(.zero)) }
		
		// See protocol.
		@ArrayBuilder<Lower.Effect>
		func lowered(in context: inout ()) throws -> [Lower.Effect] {
			switch self {
				
				case .copy(let dataType, into: let destination, from: let source):
				Lower.Effect.copy(dataType, into: destination, from: source)
				
				case .compute(let destination, let lhs, let operation, let rhs):
				Lower.Effect.compute(destination: destination, lhs, operation, rhs)
				
				case .load(let dataType, destination: let destination, address: let address, offset: let offset):
				Lower.Effect.load(dataType, destination: destination, address: address, offset: offset)
				
				case .store(let dataType, address: let address, source: let source, offset: let offset):
				Lower.Effect.store(dataType, address: address, source: source, offset: offset)
				
				case .deriveCapabilityFromLabel(destination: let destination, label: let label):
				Lower.Effect.deriveCapabilityFromLabel(destination: destination, label: label)
				
				case .deriveCapabilityFromPCC(destination: let destination, upperBits: let upperBits):
				Lower.Effect.deriveCapabilityFromPCC(destination: destination, upperBits: upperBits)
				
				case .offsetCapability(destination: let destination, source: let source, offset: let offset):
				Lower.Effect.offsetCapability(destination: destination, source: source, offset: offset)
				
				case .getCapabilityLength(destination: let destination, source: let source):
				Lower.Effect.getCapabilityLength(destination: destination, source: source)
				
				case .setCapabilityBounds(destination: let destination, base: let base, length: let length):
				Lower.Effect.setCapabilityBounds(destination: destination, base: base, length: length)
				
				case .getCapabilityAddress(destination: let destination, source: let source):
				Lower.Effect.getCapabilityAddress(destination: destination, source: source)
				
				case .setCapabilityAddress(destination: let destination, source: let source, address: let address):
				Lower.Effect.setCapabilityAddress(destination: destination, source: source, address: address)
				
				case .getCapabilityDistance(destination: let destination, cs1: let cs1, cs2: let cs2):
				Lower.Effect.getCapabilityDistance(destination: destination, cs1: cs1, cs2: cs2)
				
				case .seal(destination: let destination, source: let source, seal: let seal):
				Lower.Effect.seal(destination: destination, source: source, seal: seal)
				
				case .sealEntry(destination: let destination, source: let source):
				Lower.Effect.sealEntry(destination: destination, source: source)
				
				case .permit(let permissions, destination: let destination, source: let source, using: let permissionsRegister):
				Lower.Effect.permit(permissions, destination: destination, source: source, using: permissionsRegister)
				
				case .clear(let registers):
				Lower.Effect.clear(registers)
				
				case .branch(to: let target, let rs1, let relation, let rs2):
				Lower.Effect.branch(to: target, rs1, relation, rs2)
				
				case .jump(to: let target, link: let link):
				Lower.Effect.jump(to: target, link: link)
				
				case .invoke(target: let target, data: let data):
				Lower.Effect.invoke(target: target, data: data)
				
				case .callRuntimeRoutine(capability: let capabilityLabel, link: .zero):
				throw LoweringError.zeroRuntimeRoutineLinkRegister(capability: capabilityLabel)
				
				case .callRuntimeRoutine(capability: let capabilityLabel, link: let linkReg):
				Lower.Effect.deriveCapabilityFromLabel(destination: linkReg, label: capabilityLabel)
				Lower.Effect.load(.cap, destination: linkReg, address: linkReg, offset: 0)
				Lower.Effect.jump(to: .register(linkReg), link: linkReg)
				
			}
		}
		
		enum LoweringError : LocalizedError {
			
			/// An error indicating that a `.zero` link register is specified for calling a runtime routine with given capability.
			case zeroRuntimeRoutineLinkRegister(capability: Label)
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					case .zeroRuntimeRoutineLinkRegister(capability: let label):
					return "Cannot invoke runtime routine “\(label)” with link register cnull."
				}
			}
			
		}
		
	}
	
}
