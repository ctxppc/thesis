// Glyco © 2021–2022 Constantino Tsarouhas

extension RV {
	
	/// A CHERI-RISC-V instruction.
	///
	/// Each instruction maps to exactly one machine instruction or pseudo-instruction.
	///
	/// As a convention, the following verbiage is used in the context of data movement:
	/// * a datum is *loaded from* or *stored in* memory;
	/// * a datum is *retrieved from* or *put in* a register; and
	/// * a datum is *copied from* a register *to* a register.
	public enum Instruction : Codable, Equatable, SimplyLowerable {
		
		/// An instruction that copies the word from `source` to `destination`.
		case copyWord(destination: Register, source: Register)
		
		/// An instruction that copies the capability from `source` to `destination`.
		case copyCapability(destination: Register, source: Register)
		
		/// An instruction that performs *x* `operation` *y* and puts the result in `rd`, where *x* is the value in `rs1` and *y* is the value in `rs2`.
		case computeWithRegister(operation: BinaryOperator, rd: Register, rs1: Register, rs2: Register)
		
		/// An instruction that performs *x* `operation` `imm` and puts the result in `rd`, where *x* is the value in `rs1`.
		case computeWithImmediate(operation: BinaryOperator, rd: Register, rs1: Register, imm: Int)
		
		/// An instruction that loads the word byte memory at the address in `address`, with the address offset by `offset`.
		case loadByte(destination: Register, address: Register)
		
		/// An instruction that loads the word from memory at the address in `address` and puts it in `destination`.
		case loadSignedWord(destination: Register, address: Register)
		
		/// An instruction that loads the capability from memory at the address in `address` and puts it in `destination`.
		case loadCapability(destination: Register, address: Register)
		
		/// An instruction that retrieves the byte from `source` and stores it in memory at the address in `address`.
		case storeByte(source: Register, address: Register)
		
		/// An instruction that retrieves the word from `source` and stores it in memory at the address in `address`.
		case storeSignedWord(source: Register, address: Register)
		
		/// An instruction that retrieves the capability from `source` and stores it in memory at the address in `address`.
		case storeCapability(source: Register, address: Register)
		
		/// An instruction that offsets the capability in `source` by the offset in `offset` and puts it in `destination`.
		case offsetCapability(destination: Register, source: Register, offset: Register)
		
		/// An instruction that offsets the capability in `source` by `offset` and puts it in `destination`.
		case offsetCapabilityWithImmediate(destination: Register, source: Register, offset: Int)
		
		/// An instruction that determines the (integer) length of the capability in `source` and puts it in `destination`.
		case getCapabilityLength(destination: Register, source: Register)
		
		/// An instruction that copies the capability from `source` to `datum` then adjusts its length to `length` bytes.
		///
		/// If the bounds cannot be represented exactly, the base may be adjusted downwards and the length upwards. A hardware exception is raised if the adjusted bounds exceed the bounds of the source capability.
		case setCapabilityBounds(destination: Register, source: Register, length: Int)
		
		/// An instruction that determines the (integer) address of the capability in `source` and puts it in `destination`.
		case getCapabilityAddress(destination: Register, source: Register)
		
		/// An instruction that copies copies `destination` to `source`, replacing the address with the integer in `address`.
		case setCapabilityAddress(destination: Register, source: Register, address: Register)
		
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
		
		/// An instruction that jumps to `target`.
		case jump(target: Label)
		
		/// An instruction that jumps to the (possibly unsealed) address in `target`.
		///
		/// A hardware exception is raised if `target` doesn't contain a valid capability that permits execution or if the capability is sealed (except as a sentry).
		case jumpWithRegister(target: Register)
		
		/// An instruction that puts the next PCC in `cra`, then jumps to `target`.
		case call(target: Label)
		
		/// An instruction that puts the next PCC in `link`, then jumps to the (possibly unsealed) address in `target`.
		///
		/// A hardware exception is raised if `target` doesn't contain a valid capability that permits execution or if the capability is sealed (except as a sentry).
		case callWithRegister(target: Register, link: Register)
		
		/// An instruction that jumps to the address in `target` after unsealing it, and puts the datum in `data` in `ct6` after unsealing it.
		///
		/// A hardware exception is raised
		/// * if `target` or `data` don't contain valid capabilities with the same object type that permit invocation,
		/// * if `target` contains a capability that doesn't permit execution,
		/// * if `data` contains a capability that permits execution, or
		/// * if `target` contains a capability that points outside its bounds.
		case invoke(target: Register, data: Register)
		
		/// An instruction that jumps to address *x*, where *x* is the value in `cra`.
		case `return`
		
		// See protocol.
		func lowered(in context: inout Context) -> String {
			switch self {
				
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
				
				case .loadByte(destination: let rd, address: let address):
				return "lbu.cap \(rd.x), 0(\(address.c))"
				
				case .loadSignedWord(destination: let rd, address: let address):
				return "lw.cap \(rd.x), 0(\(address.c))"
				
				case .loadCapability(destination: let cd, address: let address):
				return "lc.cap \(cd.c), 0(\(address.c))"
				
				case .storeByte(source: let rs, address: let address):
				return "sbu.cap \(rs.x), 0(\(address.c))"
				
				case .storeSignedWord(source: let rs, address: let address):
				return "sw.cap \(rs.x), 0(\(address.c))"
				
				case .storeCapability(source: let cs, address: let address):
				return "sc.cap \(cs.c), 0(\(address.c))"
				
				case .offsetCapability(destination: let destination, source: let source, offset: let offset):
				return "cincoffset \(destination.c), \(source.c), \(offset.x)"
				
				case .offsetCapabilityWithImmediate(destination: let destination, source: let source, offset: let offset):
				return "cincoffsetimm \(destination.c), \(source.c), \(offset)"
				
				case .getCapabilityLength(destination: let destination, source: let source):
				return "cgetlen \(destination.x), \(source.c)"
				
				case .setCapabilityBounds(destination: let destination, source: let source, length: let length):
				return "csetboundsimm \(destination.c), \(source.c), \(length)"
				
				case .getCapabilityAddress(destination: let destination, source: let source):
				return "cgetaddr \(destination.x), \(source.c)"
				
				case .setCapabilityAddress(destination: let destination, source: let source, address: let address):
				return "csetaddr \(destination.c), \(source.c), \(address.x)"
				
				case .seal(destination: let destination, source: let source, seal: let seal):
				return "cseal \(destination.c), \(source.c), \(seal.c)"
				
				case .sealEntry(destination: let destination, source: let source):
				return "csealentry \(destination.c), \(source.c)"
				
				case .permit(destination: let destination, source: let source, mask: let mask):
				return "candperm \(destination.c), \(source.c), \(mask.x)"
				
				case .clear(quarter: let quarter, mask: let mask):
				return "cclear \(quarter), \(mask)"
				
				case .branch(rs1: let rs1, relation: let relation, rs2: let rs2, target: let target):
				return "b\(relation.rawValue) \(rs1.x), \(rs2.x), \(target.rawValue)"
				
				case .jump(target: let target):
				return "j \(target.rawValue)"
				
				case .jumpWithRegister(target: let target):
				return "cjr \(target.c)"
				
				case .call(target: let target):
				return "ccall \(target.rawValue)"
				
				case .callWithRegister(target: let target, link: let link):
				return "cjalr \(target.c), \(link.c)"
				
				case .invoke(target: let target, data: let data):
				return "cinvoke \(target.c), \(data.c)"
				
				case .return:
				return "ret.cap"
				
			}
		}
		
	}
	
}
