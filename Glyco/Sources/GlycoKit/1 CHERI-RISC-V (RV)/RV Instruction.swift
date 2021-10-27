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
		
		/// An instruction that retrieves the word in memory at the address in `cs`, with the address offset by `imm`, and stores it in `rd`.
		case loadWord(rd: Register, ca: Register, imm: Int)
		
		/// An instruction that retrieves the capability in memory at the address in `cs`, with the address offset by `imm`, and stores it in `cd`.
		case loadCapability(cd: Register, ca: Register, imm: Int)
		
		/// An instruction that retrieves the word in `rs` and stores it in memory at the address in `ca`, with the address offset by `imm`.
		case storeWord(rs: Register, ca: Register, imm: Int)
		
		/// An instruction that retrieves the capability in `cs` and stores it in memory at the address in `ca`, with the address offset by `imm`.
		case storeCapability(cs: Register, ca: Register, imm: Int)
		
		/// An instruction that jumps `offset` bytes forward if *x* `relation` *y*, where *x* is the value in `rs1` and *y* is the value in `rs2`.
		case branch(rs1: Register, relation: BranchRelation, rs2: Register, offset: Int)
		public enum BranchRelation : String, Codable {
			case equal = "eq"
			case unequal = "ne"
			case less = "lt"
			case greaterOrEqual = "ge"
		}
		
		/// An instruction that assigns the next PPC to `cd` and jumps to address *x*, where *x* is the value in `cs1`.
		case jump(cd: Register, cs1: Register)
		
		/// An instruction that can jumped to using a label.
		indirect case labelled(Label, Instruction)
		
		/// A return instruction.
		case `return`
		
		/// Returns the assembly representation of `self`.
		public func compiled() -> String {
			switch self {
				
				case .registerRegister(operation: let operation, rd: let rd, rs1: let rs1, rs2: let rs2):
				return "\(operation) \(rd.x), \(rs1.x), \(rs2.x)"
				
				case .registerImmediate(operation: let operation, rd: let rd, rs1: let rs1, imm: let imm):
				return "\(operation)i \(rd.x), \(rs1.x), \(imm)"
				
				case .loadWord(rd: let rd, ca: let ca, imm: let imm):
				return "lw.cap \(rd.x), \(imm)(\(ca.c))"
				
				case .loadCapability(cd: let cd, ca: let ca, imm: let imm):
				return "clc \(cd.x), \(imm)(\(ca.c))"
				
				case .storeWord(rs: let rs, ca: let ca, imm: let imm):
				return "sw.cap \(rs.x), \(imm)(\(ca.c))"
				
				case .storeCapability(cs: let cs, ca: let ca, imm: let imm):
				return "clc \(cs.x), \(imm)(\(ca.c))"
				
				case .branch(rs1: let rs1, relation: let relation, rs2: let rs2, offset: let offset):
				return "b\(relation.rawValue) \(rs1.x), \(rs2.x), \(offset)"
				
				case .jump(cd: let cd, cs1: let cs1):
				return "cjalr \(cd.c), \(cs1.c)"
				
				case .labelled(let label, let instruction):
				return "\(label.rawValue): \(instruction.compiled())"
				
				case .return:
				return "cret"
				
			}
		}
		
	}
	
}
