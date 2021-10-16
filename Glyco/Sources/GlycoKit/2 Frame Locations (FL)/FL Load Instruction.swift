// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	/// An FL instruction that loads a register value from memory.
	public enum LoadInstruction : Codable {
		
		/// An instruction that retrieves the word in memory at the address in `rs1`, with the address offset by `imm`, and stores it in `rd`.
		case word(destination: Register, source: FrameCellLocation)
		
		/// Returns a representation of `self` in a lower language.
		public func lowered() -> Lower.LoadInstruction {
			switch self {
				case .word(destination: let destination, source: let source):	return .word(rd: destination, rs1: .fp, imm: source.offset)
			}
		}
		
	}
	
}

public func <- (rd: FL.Register, src: FL.FrameCellLocation) -> FL.LoadInstruction {
	.word(destination: rd, source: src)
}
