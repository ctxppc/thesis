// Glyco © 2021 Constantino Tsarouhas

/// An FL instruction that stores a register value in memory.
enum FLStoreInstruction : Codable {
	
	/// An instruction that retrieves the word in `source` and stores it in memory at the address in `destination`.
	case word(destination: FLFrameCellLocation, source: RVRegister)
	
}

extension FLStoreInstruction {
	
	/// The RV representation of `self`.
	var rvInstruction: RVStoreInstruction {
		switch self {
			case .word(destination: let destination, source: let source):	return .word(rs1: .fp, rs2: source, imm: destination.offset)
		}
	}
	
}
