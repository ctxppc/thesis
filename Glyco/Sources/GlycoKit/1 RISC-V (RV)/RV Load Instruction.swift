// Glyco © 2021 Constantino Tsarouhas

extension RV {
	
	/// An RV32I instruction that loads a register value from memory.
	public enum LoadInstruction : Codable {
		
		/// An instruction that retrieves the word in memory at the address in `rs1`, with the address offset by `imm`, and stores it in `rd`.
		case word(rd: Register, rs1: Register, imm: Int)
		
		/// Returns the assembly representation of `self`.
		public func compiled() -> String {
			switch self {
				case .word(rd: let rd, rs1: let rs1, imm: let imm):	return "lw \(rd), \(rs1), \(imm)"
			}
		}
		
	}
	
}
