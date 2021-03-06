// Glyco © 2021–2022 Constantino Tsarouhas

extension RV {
	
	//sourcery: heavyGrammar
	/// A CHERI-RISC-V instruction.
	///
	/// Each instruction maps to exactly one machine instruction or pseudo-instruction.
	///
	/// As a convention, the following verbiage is used in the context of data movement:
	/// * a datum is *loaded from* or *stored in* memory;
	/// * a datum is *retrieved from* or *put in* a register; and
	/// * a datum is *copied from* a register *to* a register.
	public enum Instruction : SimplyLowerable, Element {
		
		/// An instruction that copies the word from `source` to `destination`.
		case copyWord(destination: Register, source: Register)
		
		/// An instruction that copies the capability from `source` to `destination`.
		case copyCapability(destination: Register, source: Register)
		
		/// An instruction that performs *x* `operation` *y* and puts the result in `rd`, where *x* is the value in `rs1` and *y* is the value in `rs2`.
		case computeWithRegister(operation: BinaryOperator, rd: Register, rs1: Register, rs2: Register)
		
		/// An instruction that performs *x* `operation` `imm` and puts the result in `rd`, where *x* is the value in `rs1`.
		///
		/// `operation` cannot be `.mul`.
		case computeWithImmediate(operation: BinaryOperator, rd: Register, rs1: Register, imm: Int)
		
		/// An instruction that loads the word byte memory at the address in `address` and puts it in `destination`, offset by `offset` bytes.
		///
		/// `offset` must be in the range [-2048; 2047].
		case loadByte(destination: Register, address: Register, offset: Int)
		
		/// An instruction that loads the word from memory at the address in `address` and puts it in `destination`, offset by `offset` bytes.
		///
		/// `offset` must be in the range [-2048; 2047].
		case loadSignedWord(destination: Register, address: Register, offset: Int)
		
		/// An instruction that loads the capability from memory at the address in `address` and puts it in `destination`, offset by `offset` bytes.
		///
		/// `offset` must be in the range [-2048; 2047].
		case loadCapability(destination: Register, address: Register, offset: Int)
		
		/// An instruction that retrieves the byte from `source` and stores it in memory at the address in `address`, offset by `offset` bytes.
		///
		/// `offset` must be in the range [-2048; 2047].
		case storeByte(source: Register, address: Register, offset: Int)
		
		/// An instruction that retrieves the word from `source` and stores it in memory at the address in `address`, offset by `offset` bytes.
		///
		/// `offset` must be in the range [-2048; 2047].
		case storeSignedWord(source: Register, address: Register, offset: Int)
		
		/// An instruction that retrieves the capability from `source` and stores it in memory at the address in `address`, offset by `offset` bytes.
		///
		/// `offset` must be in the range [-2048; 2047].
		case storeCapability(source: Register, address: Register, offset: Int)
		
		/// An instruction that derives a capability from PCC to the memory location labelled `label` and puts it in `destination`.
		case deriveCapabilityFromLabel(destination: Register, label: Label)
		
		/// An instruction that derives a capability from PCC, adds `upperBits` to after left-shifting it by 12, and puts the resulting capability in `destination`.
		case deriveCapabilityFromPCC(destination: Register, upperBits: UInt)
		
		/// An instruction that offsets the capability in `source` by the offset in `offset` and puts it in `destination`.
		case offsetCapability(destination: Register, source: Register, offset: Register)
		
		/// An instruction that offsets the capability in `source` by `offset` and puts it in `destination`.
		case offsetCapabilityWithImmediate(destination: Register, source: Register, offset: Int)
		
		/// An instruction that determines the (integer) length of the capability in `source` and puts it in `destination`.
		case getCapabilityLength(destination: Register, source: Register)
		
		/// An instruction that copies the capability from `base` to `destination`, sets its base to the address of `base`, and adjusts its length to the length in `length`.
		///
		/// If the bounds cannot be represented exactly, the base may be adjusted downwards and the length upwards. A hardware exception is raised if the adjusted bounds exceed the bounds of the source capability.
		case setCapabilityBounds(destination: Register, base: Register, length: Register)
		
		/// An instruction that copies the capability from `base` to `destination`, sets its base to the address of `base`, and adjusts its length to `length` bytes.
		///
		/// If the bounds cannot be represented exactly, the base may be adjusted downwards and the length upwards. A hardware exception is raised if the adjusted bounds exceed the bounds of the source capability.
		case setCapabilityBoundsWithImmediate(destination: Register, base: Register, length: Int)
		
		/// An instruction that determines the (integer) address of the capability in `source` and puts it in `destination`.
		case getCapabilityAddress(destination: Register, source: Register)
		
		/// An instruction that copies copies `destination` to `source`, replacing the address with the integer in `address`.
		case setCapabilityAddress(destination: Register, source: Register, address: Register)
		
		/// An instruction that subtracts the address in `cs2` from the address in `cs1` and puts the difference in `destination`.
		case getCapabilityDistance(destination: Register, cs1: Register, cs2: Register)
		
		/// An instruction that seals the capability in `source` using the address of the capability in `seal` as the object type and puts it in `destination`.
		///
		/// A hardware exception is raised if `source` or `seal` don't contain valid, unsealed capabilities, or if `seal` contains a capability that doesn't permit sealing, points outside its bounds, or whose address isn't a valid object type.
		case seal(destination: Register, source: Register, seal: Register)
		
		/// An instruction that seals the capability in `source` as a sentry and puts it in `destination`.
		///
		/// A hardware exception is raised if `source` doesn't contain a valid, unsealed capability that permits execution.
		case sealEntry(destination: Register, source: Register)
		
		/// An instruction that derives `destination` from `source`, keeping at most the permissions specified in the bitmask in `mask`.
		///
		/// The capability in `destination` contains a permission *p* iff *p* is in the capability in `source` **and** if *p* is among the specified permissions.
		///
		/// A hardware exception is raised if `source` doesn't contain a valid, unsealed capability.
		case permit(destination: Register, source: Register, mask: Register)
		
		/// An instruction that clears registers 8 × `quarter` + *i* where *i* is the *i*th bit of `mask`.
		case clear(quarter: Int, mask: UInt8)
		
		/// An instruction that jumps to `target` if *x* `relation` *y*, where *x* is the value in `rs1` and *y* is the value in `rs2`.
		case branch(rs1: Register, relation: BranchRelation, rs2: Register, target: Label)
		
		/// An instruction that puts the next PCC in `link`, then jumps to `target`.
		case jump(target: Label, link: Register)
		
		/// An instruction that puts the next PCC in `link`, then jumps to the (possibly unsealed) address in `target`.
		///
		/// A hardware exception is raised if `target` doesn't contain a valid capability that permits execution or if the capability is sealed (except as a sentry).
		case jumpWithRegister(target: Register, link: Register)
		
		/// An instruction that jumps to the address in `target` after unsealing it, and puts the datum in `data` in `ct6` after unsealing it.
		///
		/// A hardware exception is raised
		/// * if `target` or `data` don't contain valid capabilities with the same object type that permit invocation,
		/// * if `target` contains a capability that doesn't permit execution,
		/// * if `data` contains a capability that permits execution, or
		/// * if `target` contains a capability that points outside its bounds.
		case invoke(target: Register, data: Register)
		
		// See protocol.
		func lowered(in context: inout Context) -> String {
			switch self {
				
				case .computeWithRegister(operation: .add, rd: .zero, rs1: .zero, rs2: .zero):
				return "nop"
				
				case .copyWord(destination: let destination, source: let source):
				return "mv \(destination.x), \(source.x)"
				
				case .copyCapability(destination: let destination, source: let source):
				return "cmove \(destination.c), \(source.c)"
				
				case .computeWithRegister(operation: let operation, rd: let rd, rs1: let rs1, rs2: let rs2):
				return "\(operation.rawValue) \(rd.x), \(rs1.x), \(rs2.x)"
				
				case .computeWithImmediate(operation: .sub, rd: let rd, rs1: let rs1, imm: let imm) where imm >= 0:
				return "addi \(rd.x), \(rs1.x), -\(imm)"
				
				case .computeWithImmediate(operation: .sub, rd: let rd, rs1: let rs1, imm: let imm):
				return "addi \(rd.x), \(rs1.x), \(imm)"
				
				case .computeWithImmediate(operation: let operation, rd: let rd, rs1: let rs1, imm: let imm):
				return "\(operation.rawValue)i \(rd.x), \(rs1.x), \(imm)"
				
				case .loadByte(destination: let rd, address: let address, offset: let offset):
				return "clbu \(rd.x), \(offset)(\(address.c))"
				
				case .loadSignedWord(destination: let rd, address: let address, offset: let offset):
				return "clw \(rd.x), \(offset)(\(address.c))"
				
				case .loadCapability(destination: let cd, address: let address, offset: let offset):
				return "clc \(cd.c), \(offset)(\(address.c))"
				
				case .storeByte(source: let rs, address: let address, offset: let offset):
				return "csbu \(rs.x), \(offset)(\(address.c))"
				
				case .storeSignedWord(source: let rs, address: let address, offset: let offset):
				return "csw \(rs.x), \(offset)(\(address.c))"
				
				case .storeCapability(source: let cs, address: let address, offset: let offset):
				return "csc \(cs.c), \(offset)(\(address.c))"
				
				case .deriveCapabilityFromLabel(destination: let cd, label: let label):
				return "cllc \(cd.c), \(label.rawValue)"
				
				case .deriveCapabilityFromPCC(destination: let cd, upperBits: let imm):
				return "auipcc \(cd.c), \(imm)"
				
				case .offsetCapability(destination: let destination, source: let source, offset: let offset):
				return "cincoffset \(destination.c), \(source.c), \(offset.x)"
				
				case .offsetCapabilityWithImmediate(destination: let destination, source: let source, offset: let offset):
				return "cincoffsetimm \(destination.c), \(source.c), \(offset)"
				
				case .getCapabilityLength(destination: let destination, source: let source):
				return "cgetlen \(destination.x), \(source.c)"
				
				case .setCapabilityBounds(destination: let destination, base: let base, length: let length):
				return "csetbounds \(destination.c), \(base.c), \(length.x)"
				
				case .setCapabilityBoundsWithImmediate(destination: let destination, base: let base, length: let length):
				return "csetboundsimm \(destination.c), \(base.c), \(length)"
				
				case .getCapabilityAddress(destination: let destination, source: let source):
				return "cgetaddr \(destination.x), \(source.c)"
				
				case .setCapabilityAddress(destination: let destination, source: let source, address: let address):
				return "csetaddr \(destination.c), \(source.c), \(address.x)"
				
				case .getCapabilityDistance(destination: let destination, cs1: let cs1, cs2: let cs2):
				return "csub \(destination.x), \(cs1.c), \(cs2.c)"
				
				case .seal(destination: let destination, source: let source, seal: let seal):
				return "cseal \(destination.c), \(source.c), \(seal.c)"
				
				case .sealEntry(destination: let destination, source: let source):
				return "csealentry \(destination.c), \(source.c)"
				
				case .permit(destination: let destination, source: let source, mask: let mask):
				return "candperm \(destination.c), \(source.c), \(mask.x)"
				
				case .clear(quarter: let quarter, mask: let mask):
				// LLVM doesn't seem to support cclear and clear is not available on merged-register ISAs, so it's time to bit-fiddle!
				//                  0x7f    0xe   q  m[7:5]  0x0  m[4:0]  0x5b
				let instruction = 0b1111111_01110_00_000_____000__00000___1011011 as UInt32
				let quarterMask = UInt32(quarter) << 18
				let highMaskMask = (UInt32(mask) & 0b11100000) << (15 - 5)
				let lowMaskMask = (UInt32(mask) & 0b00011111) << 7
				let encoding = (instruction | quarterMask | highMaskMask | lowMaskMask)
				return ".4byte \(encoding) # cclear \(quarter), \(mask)"
				
				case .branch(rs1: let rs1, relation: let relation, rs2: let rs2, target: let target):
				return "b\(relation.rawValue) \(rs1.x), \(rs2.x), \(target.rawValue)"
				
				case .jump(target: let target, link: let link):
				return "cjal \(link.c), \(target.rawValue)"
				
				case .jumpWithRegister(target: let target, link: let link):
				return "cjalr \(link.c), \(target.c)"
				
				case .invoke(target: let target, data: let data):
				return "cinvoke \(target.c), \(data.c)"
				
			}
		}
		
	}
	
}
