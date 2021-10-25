// Glyco © 2021 Constantino Tsarouhas

extension RV {
	
	/// A CHERI-RISC-V instruction.
	///
	/// Each instruction maps to exactly one assembly instruction.
	public enum Instruction : Codable {
		
		/// Performs *x* `operation` *y* and assigns the result to `rd`, where *x* is the value in `rs1` and *y* is the value in `rs2`.
		case registerRegister(operation: BinaryOperation, rd: Register, rs1: Register, rs2: Register)
		
		/// Performs *x* `operation` `imm` and assigns the result to `rd`, where *x* is the value in `rs1`.
		case registerImmediate(operation: BinaryOperation, rd: Register, rs1: Register, imm: Int)
		
		/// An operation between two registers.
		public enum BinaryOperation : String, Codable {
			case add, subtract = "sub"
			case and, or, xor
			case leftShift = "sll", zeroExtendingRightShift = "srl", msbExtendingRightShift = "sra"
		}
		
		/// An instruction that retrieves the word in memory at the address in `rs1`, with the address offset by `imm`, and stores it in `rd`.
		case load(rd: Register, rs1: Register, imm: Int)
		
		/// An instruction that retrieves the word in `rs2` and stores it in memory at the address in `rs1`, with the address offset by `imm`.
		case store(rs1: Register, rs2: Register, imm: Int)
		
		/// A return instruction.
		case `return`
		
		/// Returns the assembly representation of `self`.
		public func compiled() -> String {
			switch self {
				
				case .registerRegister(operation: let operation, rd: let rd, rs1: let rs1, rs2: let rs2):
				return "\(operation) \(rd), \(rs1), \(rs2)"
				
				case .registerImmediate(operation: let operation, rd: let rd, rs1: let rs1, imm: let imm):
				return "\(operation)i \(rd), \(rs1), \(imm)"
				
				case .load(rd: let rd, rs1: let rs1, imm: let imm):
				return "lw.cap \(rd), \(imm)(\(rs1.c))"
				
				case .store(rs1: let rs1, rs2: let rs2, imm: let imm):
				return "sw.cap \(rs1), \(imm)(\(rs2.c))"
				
				case .return:
				return "cret"
				
			}
		}
		
	}
	
}
