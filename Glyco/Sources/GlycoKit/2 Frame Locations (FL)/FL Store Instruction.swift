// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	/// An FL instruction that stores a register value in memory.
	enum StoreInstruction : Codable {
		
		/// An instruction that retrieves the word in `source` and stores it in memory at the address in `destination`.
		case word(destination: FrameCellLocation, source: RV.Register)
		
	}
	
}

extension FL.StoreInstruction {
	
	/// The RV representation of `self`.
	var rvInstruction: RV.StoreInstruction {
		switch self {
			case .word(destination: let destination, source: let source):	return .word(rs1: .fp, rs2: source, imm: destination.offset)
		}
	}
	
}

func <- (dest: FL.FrameCellLocation, src: RV.Register) -> FL.StoreInstruction {
	.word(destination: dest, source: src)
}
