// Glyco © 2021 Constantino Tsarouhas

/// An FL instruction that loads a register value from memory.
enum FLLoadInstruction : Codable {
	
	/// An instruction that retrieves the word in memory at the address in `rs1`, with the address offset by `imm`, and stores it in `rd`.
	case word(destination: RVRegister, source: FLFrameCellLocation)
	
}

extension FLLoadInstruction {
	
	/// The RV representation of `self`.
	var rvInstruction: RVLoadInstruction {
		switch self {
			case .word(destination: let destination, source: let source):	return .word(rd: destination, rs1: .fp, imm: source.offset)
		}
	}
	
}
