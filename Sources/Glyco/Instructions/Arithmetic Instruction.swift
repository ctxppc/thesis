// Glyco © 2021 Constantino Tsarouhas

/// An arithmetic instruction.
enum ArithmeticInstruction {
	case add(rd: Register, rs1: Register, rs2: Register)
	case addImm(rd: Register, rs1: Register, imm: Int)
	case subtract(rd: Register, rs1: Register, rs2: Register)
	case and(rd: Register, rs1: Register, rs2: Register)
	case andImm(rd: Register, rs1: Register, imm: Int)
	case or(rd: Register, rs1: Register, rs2: Register)
	case orImm(rd: Register, rs1: Register, imm: Int)
	case xor(rd: Register, rs1: Register, rs2: Register)
	case xorImm(rd: Register, rs1: Register, imm: Int)
	case leftShift(rd: Register, rs1: Register, rs2: Register)
	case leftShiftImm(rd: Register, rs1: Register, imm: Int)
	case rightShift(rd: Register, rs1: Register, rs2: Register, extendingMSB: Bool = false)
	case rightShiftImm(rd: Register, rs1: Register, imm: Int, extendingMSB: Bool = false)
}

extension ArithmeticInstruction : Instruction {
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
		}
	}
}
