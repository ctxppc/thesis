// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	/// An FL instruction that loads a register value from memory.
	enum LoadInstruction : Codable {
		
		/// An instruction that retrieves the word in memory at the address in `rs1`, with the address offset by `imm`, and stores it in `rd`.
		case word(destination: RV.Register, source: FrameCellLocation)
		
	}
	
}

extension FL.LoadInstruction {
	
	/// The RV representation of `self`.
	var rvInstruction: RV.LoadInstruction {
		switch self {
			case .word(destination: let destination, source: let source):	return .word(rd: destination, rs1: .fp, imm: source.offset)
		}
	}
	
}

func <- (rd: RV.Register, src: FL.FrameCellLocation) -> FL.LoadInstruction {
	.word(destination: rd, source: src)
}
