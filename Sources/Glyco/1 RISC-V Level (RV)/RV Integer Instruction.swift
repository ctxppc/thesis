// Glyco © 2021 Constantino Tsarouhas

/// An RV32I (base integer) instruction.
enum RVIntegerInstruction : Codable {
	
	/// Assigns the sum of the integers in `rs1` and `rs2` to `rd`.
	case add(rd: RVRegister, rs1: RVRegister, rs2: RVRegister)
	
	/// Assigns the sum of `imm` and the integer in `rs1` to `rd`.
	case addImm(rd: RVRegister, rs1: RVRegister, imm: Int)
	
	/// Assigns the difference of the integers in `rs1` and `rs2` to `rd`.
	case subtract(rd: RVRegister, rs1: RVRegister, rs2: RVRegister)
	
	/// Assigns the bitwise conjunction of the bitfields in `rs1` and `rs2` to `rd`.
	case and(rd: RVRegister, rs1: RVRegister, rs2: RVRegister)
	
	/// Assigns the bitwise conjunction of `imm` and the bitfield in `rs1` to `rd.
	case andImm(rd: RVRegister, rs1: RVRegister, imm: Int)
	
	/// Assigns the bitwise disjunction of the bitfields in `rs1` and `rs2` to `rd`.
	case or(rd: RVRegister, rs1: RVRegister, rs2: RVRegister)
	
	/// Assigns the bitwise disjunction of `imm` and the bitfield in `rs1` to `rd.
	case orImm(rd: RVRegister, rs1: RVRegister, imm: Int)
	
	/// Assigns the bitwise exclusive disjunction of the bitfields in `rs1` and `rs2` to `rd`.
	case xor(rd: RVRegister, rs1: RVRegister, rs2: RVRegister)
	
	/// Assigns the bitwise exclusive disjunction of `imm` and the bitfield in `rs1` to `rd.
	case xorImm(rd: RVRegister, rs1: RVRegister, imm: Int)
	
	/// Left-shifts the bitfield in `rs1` by as many bits as the integer in `rs2` and assigns the result to `rd`.
	case leftShift(rd: RVRegister, rs1: RVRegister, rs2: RVRegister)
	
	/// Left-shifts the bitfield in `rs1` by `rs2` bits and assigns the result to `rd`.
	case leftShiftImm(rd: RVRegister, rs1: RVRegister, imm: Int)
	
	/// Right-shifts the bitfield in `rs1` by as many bits as the integer in `rs2` and assigns the result to `rd`, extending the MSB if `extendingMSB` is `true` and extending with zero bits otherwise.
	case rightShift(rd: RVRegister, rs1: RVRegister, rs2: RVRegister, extendingMSB: Bool = false)
	
	/// Right-shifts the bitfield in `rs1` by `rs2` bits and assigns the result to `rd`, extending the MSB if `extendingMSB` is `true` and extending with zero bits otherwise.
	case rightShiftImm(rd: RVRegister, rs1: RVRegister, imm: Int, extendingMSB: Bool = false)
	
	/// Loads the word in memory at the address in `rs1` and offset by `imm` to `rd`.
	case loadWord(rd: RVRegister, rs1: RVRegister, imm: Int)
	
}

extension RVIntegerInstruction {
	
	/// The assembly representation of `self`.
	var assembly: String {
		switch self {
			case .add(rd: let rd, rs1: let rs1, rs2: let rs2):									return "add \(rd), \(rs1), \(rs2)"
			case .addImm(rd: let rd, rs1: let rs1, imm: let imm):								return "addi \(rd), \(rs1), \(imm)"
			case .subtract(rd: let rd, rs1: let rs1, rs2: let rs2):								return "sub \(rd), \(rs1), \(rs2)"
			case .and(rd: let rd, rs1: let rs1, rs2: let rs2):									return "and \(rd), \(rs1), \(rs2)"
			case .andImm(rd: let rd, rs1: let rs1, imm: let imm):								return "andi \(rd), \(rs1), \(imm)"
			case .or(rd: let rd, rs1: let rs1, rs2: let rs2):									return "or \(rd), \(rs1), \(rs2)"
			case .orImm(rd: let rd, rs1: let rs1, imm: let imm):								return "ori \(rd), \(rs1), \(imm)"
			case .xor(rd: let rd, rs1: let rs1, rs2: let rs2):									return "xor \(rd), \(rs1), \(rs2)"
			case .xorImm(rd: let rd, rs1: let rs1, imm: let imm):								return "xori \(rd), \(rs1), \(imm)"
			case .leftShift(rd: let rd, rs1: let rs1, rs2: let rs2):							return "sll \(rd), \(rs1), \(rs2)"
			case .leftShiftImm(rd: let rd, rs1: let rs1, imm: let imm):							return "slli \(rd), \(rs1), \(imm)"
			case .rightShift(rd: let rd, rs1: let rs1, rs2: let rs2, extendingMSB: false):		return "srl \(rd), \(rs1), \(rs2)"
			case .rightShift(rd: let rd, rs1: let rs1, rs2: let rs2, extendingMSB: true):		return "sra \(rd), \(rs1), \(rs2)"
			case .rightShiftImm(rd: let rd, rs1: let rs1, imm: let imm, extendingMSB: false):	return "srli \(rd), \(rs1), \(imm)"
			case .rightShiftImm(rd: let rd, rs1: let rs1, imm: let imm, extendingMSB: true):	return "srai \(rd), \(rs1), \(imm)"
			case .loadWord(rd: let rd, rs1: let rs1, imm: let imm):								return "lw \(rd), \(rs1), \(imm)"
		}
	}
	
}
