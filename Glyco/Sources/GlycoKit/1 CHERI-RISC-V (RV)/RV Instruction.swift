// Glyco © 2021 Constantino Tsarouhas

extension RV {
	
	/// A CHERI-RISC-V instruction.
	///
	/// Each instruction maps to exactly one assembly instruction.
	///
	/// As a convention, the following verbiage is used in the context of data movement:
	/// * a datum is *loaded from* or *stored in* memory;
	/// * a datum is *retrieved from* or *put in* a register; and
	/// * a datum is *copied from* a register *to* a register.
	public enum Instruction : Codable {
		
		/// An instruction that copies the datum from `source` to `destination`.
		case copy(DataType, destination: Register, source: Register)
		
		/// An instruction that performs *x* `operation` *y* and puts the result in `rd`, where *x* is the value in `rs1` and *y* is the value in `rs2`.
		case registerRegister(operation: BinaryOperator, rd: Register, rs1: Register, rs2: Register)
		
		/// An instruction that performs *x* `operation` `imm` and puts the result in `rd`, where *x* is the value in `rs1`.
		case registerImmediate(operation: BinaryOperator, rd: Register, rs1: Register, imm: Int)
		
		/// An instruction that loads the datum of type `type` from memory at the address in `address`, with the address offset by `offset`, and puts it in `destination`.
		case load(DataType, destination: Register, address: Register, offset: Int)
		
		/// An instruction that retrieves the datum of type `type` from `source` and stores it in memory at the address in `address`, with the address offset by `offset`.
		case store(DataType, source: Register, address: Register, offset: Int)
		
		/// An instruction that jumps to `target` if *x* `relation` *y*, where *x* is the value in `rs1` and *y* is the value in `rs2`.
		case branch(rs1: Register, relation: BranchRelation, rs2: Register, target: Label)
		
		/// An instruction that puts the PCC in `cd` then jumps to address *x*, where *x* is the value in `cs1`.
		case jump(cd: Register, cs1: Register)
		
		/// An instruction that can be jumped to using given label.
		indirect case labelled(Label, Instruction)
		
		/// A return instruction.
		case `return`
		
		/// Returns the assembly representation of `self`.
		public func compiled() -> String {
			switch self {
				
				case .copy(.word, destination: let destination, source: let source):
				return "mv \(destination.x), \(source.x)"
				
				case .copy(.capability, destination: let destination, source: let source):
				return "cmove \(destination.c), \(source.c)"
				
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
