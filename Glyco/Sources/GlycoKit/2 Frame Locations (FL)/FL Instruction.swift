// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	/// A CHERI-RISC-V instruction.
	///
	/// These instructions map one to one to assembly instructions.
	public enum Instruction : Codable {
		
		/// Computes `value` and assigns the result to `rd`.
		case assign(rd: Register, value: BinaryExpression)
		
		/// An instruction that retrieves the word in memory at the address in `rs1`, with the address offset by `imm`, and stores it in `rd`.
		case load(destination: Register, source: FrameCellLocation)
		
		/// An instruction that retrieves the word in `source` and stores it in memory at the address in `destination`.
		case store(destination: FrameCellLocation, source: Register)
		
		/// Returns a representation of `self` in a lower language.
		func lowered(context: inout Context) -> Lower.Instruction {
			switch self {
				
				case .assign(rd: let rd, value: .registerRegister(rs1: let rs1, operation: let operation, rs2: let rs2)):
				return .registerRegister(operation: operation, rd: rd, rs1: rs1, rs2: rs2)
				
				case .assign(rd: let rd, value: .registerImmediate(rs1: let rs1, operation: let operation, imm: let imm)):
				return .registerImmediate(operation: operation, rd: rd, rs1: rs1, imm: imm)
				
				case .load(destination: let destination, source: let source):
				return .load(rd: destination, rs1: .fp, imm: source.offset)
				
				case .store(destination: let destination, source: let source):
				return .store(rs1: .fp, rs2: source, imm: destination.offset)
				
			}
		}
		
	}
	
}

public func <- (rd: FL.Register, value: FL.BinaryExpression) -> FL.Instruction {
	.assign(rd: rd, value: value)
}

public func <- (rd: FL.Register, imm: Int) -> FL.Instruction {
	rd <- FL.Register.zero + imm
}

public func <- (rd: FL.Register, rs: FL.Register) -> FL.Instruction {
	rd <- rs + .zero
}

public func <- (rd: FL.Register, src: FL.FrameCellLocation) -> FL.Instruction {
	.load(destination: rd, source: src)
}

public func <- (dest: FL.FrameCellLocation, src: FL.Register) -> FL.Instruction {
	.store(destination: dest, source: src)
}
