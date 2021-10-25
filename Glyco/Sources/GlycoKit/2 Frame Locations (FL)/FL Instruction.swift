// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	/// A CHERI-RISC-V instruction.
	///
	/// These instructions map one to one to assembly instructions.
	public enum Instruction : Codable {
		
		/// Performs *x* `operation` *y* and assigns the result to `rd`, where *x* is the value in `rs1` and *y* is the value in `rs2`.
		case registerRegister(operation: BinaryOperation, rd: Register, rs1: Register, rs2: Register)
		
		/// Performs *x* `operation` `imm` and assigns the result to `rd`, where *x* is the value in `rs1`.
		case registerImmediate(operation: BinaryOperation, rd: Register, rs1: Register, imm: Int)
		
		/// An integral operation.
		public typealias BinaryOperation = Lower.Instruction.BinaryOperation
		
		/// An instruction that retrieves the word in memory at the address in `rs1`, with the address offset by `imm`, and stores it in `rd`.
		case load(destination: Register, source: FrameCellLocation)
		
		/// An instruction that retrieves the word in `source` and stores it in memory at the address in `destination`.
		case store(destination: FrameCellLocation, source: Register)
		
		/// Returns a representation of `self` in a lower language.
		func lowered(context: inout Context) -> Lower.Instruction {
			switch self {
				
				case .registerRegister(operation: let operation, rd: let rd, rs1: let rs1, rs2: let rs2):
				return .registerRegister(operation: operation, rd: rd, rs1: rs1, rs2: rs2)
				
				case .registerImmediate(operation: let operation, rd: let rd, rs1: let rs1, imm: let imm):
				return .registerImmediate(operation: operation, rd: rd, rs1: rs1, imm: imm)
				
				case .load(destination: let destination, source: let source):
				return .load(rd: destination, rs1: .fp, imm: source.offset)
				
				case .store(destination: let destination, source: let source):
				return .store(rs1: .fp, rs2: source, imm: destination.offset)
				
			}
		}
		
	}
	
}

public func <- (rd: FL.Register, imm: Int) -> FL.Instruction {
	.registerImmediate(operation: .add, rd: rd, rs1: .zero, imm: imm)
}

public func <- (rd: FL.Register, rs: FL.Register) -> FL.Instruction {
	.registerRegister(operation: .add, rd: rd, rs1: rs, rs2: .zero)
}

public func <- (rd: FL.Register, binop: FL.BinaryExpression) -> FL.Instruction {
	.registerRegister(operation: binop.operation, rd: rd, rs1: binop.firstOperand, rs2: binop.secondOperand)
}

public func <- (rd: FL.Register, src: FL.FrameCellLocation) -> FL.Instruction {
	.load(destination: rd, source: src)
}

public func <- (dest: FL.FrameCellLocation, src: FL.Register) -> FL.Instruction {
	.store(destination: dest, source: src)
}
