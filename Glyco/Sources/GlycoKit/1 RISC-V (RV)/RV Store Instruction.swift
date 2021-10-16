// Glyco © 2021 Constantino Tsarouhas

extension RV {
	
	/// An RV32I instruction that stores a register value in memory.
	public enum StoreInstruction : Codable {
		
		/// An instruction that retrieves the word in `rs2` and stores it in memory at the address in `rs1`, with the address offset by `imm`.
		case word(rs1: Register, rs2: Register, imm: Int)
		
		/// Returns the assembly representation of `self`.
		public func compiled() -> String {
			switch self {
				case .word(rs1: let rs1, rs2: let rs2, imm: let imm):	return "sw \(rs1), \(rs2), \(imm)"
			}
		}
		
	}
	
}
