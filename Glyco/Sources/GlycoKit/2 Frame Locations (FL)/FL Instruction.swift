// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	/// A CHERI-RISC-V instruction.
	///
	/// These instructions map one to one to assembly instructions.
	public enum Instruction : Codable {
		
		/// Computes `value` and assigns the result to `rd`.
		case assign(rd: Register, value: BinaryExpression)
		
		/// An instruction that retrieves the word in memory at the address in `rs1`, with the address offset by `imm`, and stores it in `rd`.
		case load(DataType, destination: Register, source: FrameCellLocation)
		
		/// An instruction that retrieves the word in `source` and stores it in memory at the address in `destination`.
		case store(DataType, destination: FrameCellLocation, source: Register)
		
		/// Returns a representation of `self` in a lower language.
		func lowered(context: inout Context) -> Lower.Instruction {
			switch self {
				
				case .assign(rd: let rd, value: .registerRegister(rs1: let rs1, operation: let operation, rs2: let rs2)):
				return .registerRegister(operation: operation, rd: rd, rs1: rs1, rs2: rs2)
				
				case .assign(rd: let rd, value: .registerImmediate(rs1: let rs1, operation: let operation, imm: let imm)):
				return .registerImmediate(operation: operation, rd: rd, rs1: rs1, imm: imm)
				
				case .load(let type, destination: let destination, source: let source):
				return .load(type, destination: destination, address: .fp, offset: source.offset)
				
				case .store(let type, destination: let destination, source: let source):
				return .store(type, source: source, address: .fp, offset: destination.offset)
				
			}
		}
		
	}
	
	public typealias DataType = Lower.DataType
	
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
	.load(.word, destination: rd, source: src)		// TODO: Capability support
}

public func <- (dest: FL.FrameCellLocation, src: FL.Register) -> FL.Instruction {
	.store(.word, destination: dest, source: src)	// TODO: Capability support
}
