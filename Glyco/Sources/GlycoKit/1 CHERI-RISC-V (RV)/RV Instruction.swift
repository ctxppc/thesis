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
		
		/// An instruction that retrieves the datum of type `type` in memory at the address in `address`, with the address offset by `offset`, and stores it in `destination`.
		case load(DataType, destination: Register, address: Register, offset: Int)
		
		/// An instruction that retrieves the datum of type `type` in `source` and stores it in memory at the address in `address`, with the address offset by `offset`.
		case store(DataType, source: Register, address: Register, offset: Int)
		
		/// An instruction that jumps `offset` bytes forward if *x* `relation` *y*, where *x* is the value in `rs1` and *y* is the value in `rs2`.
		case branch(rs1: Register, relation: BranchRelation, rs2: Register, target: Label)
		
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
				
				case .load(.word, destination: let rd, address: let address, offset: let offset):
				return "lw.cap \(rd.x), \(offset)(\(address.c))"
				
				case .load(.capability, destination: let cd, address: let address, offset: let offset):
				return "clc \(cd.x), \(offset)(\(address.c))"
				
				case .store(.word, source: let rs, address: let address, offset: let offset):
				return "sw.cap \(rs.x), \(offset)(\(address.c))"
				
				case .store(.capability, source: let cs, address: let address, offset: let offset):
				return "clc \(cs.x), \(offset)(\(address.c))"
				
				case .branch(rs1: let rs1, relation: let relation, rs2: let rs2, target: let target):
				return "b\(relation.rawValue) \(rs1.x), \(rs2.x), \(target.rawValue)"
				
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
