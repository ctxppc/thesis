// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	/// An FL instruction that stores a register value in memory.
	public enum StoreInstruction : Codable {
		
		/// An instruction that retrieves the word in `source` and stores it in memory at the address in `destination`.
		case word(destination: FrameCellLocation, source: Register)
		
		/// Returns a representation of `self` in a lower language.
		func lowered(context: inout Context) -> Lower.StoreInstruction {
			switch self {
				case .word(destination: let destination, source: let source):	return .word(rs1: .fp, rs2: source, imm: destination.offset)
			}
		}
		
	}
	
}

public func <- (dest: FL.FrameCellLocation, src: FL.Register) -> FL.StoreInstruction {
	.word(destination: dest, source: src)
}
