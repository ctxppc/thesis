// Glyco © 2021 Constantino Tsarouhas

/// An RV32I instruction that loads a register value from memory.
enum RVLoadInstruction : Codable {
	
	/// An instruction that retrieves the word in memory at the address in `rs1`, with the address offset by `imm`, and stores it in `rd`.
	case word(rd: RVRegister, rs1: RVRegister, imm: Int)
	
}

extension RVLoadInstruction {
	
	/// The assembly representation of `self`.
	var assembly: String {
		switch self {
			case .word(rd: let rd, rs1: let rs1, imm: let imm):	return "lw \(rd), \(rs1), \(imm)"
		}
	}
	
}
