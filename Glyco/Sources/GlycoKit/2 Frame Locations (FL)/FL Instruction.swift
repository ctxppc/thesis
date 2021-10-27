// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	/// A CHERI-RISC-V instruction.
	///
	/// These instructions map one to one to assembly instructions.
	public enum Instruction : Codable {
		
		/// An instruction that copies the contents of `source` into `destination`.
		case copy(DataType, destination: Register, source: Register)
		
		/// An instruction that computes `value` and assigns the result to `rd`.
		case assign(destination: Register, value: BinaryExpression)
		
		/// An instruction that retrieves the word in memory at the address in `rs1`, with the address offset by `imm`, and stores it in `rd`.
		case load(DataType, destination: Register, source: FrameCellLocation)
		
		/// An instruction that retrieves the word in `source` and stores it in memory at the address in `destination`.
		case store(DataType, destination: FrameCellLocation, source: Register)
		
		/// Returns a representation of `self` in a lower language.
		func lowered(context: inout Context) -> Lower.Instruction {
			switch self {
				
				case .copy(let type, destination: let destination, source: let source):
				return .copy(type, destination: destination, source: source)
				
				case .assign(destination: let destination, value: .registerRegister(rs1: let rs1, operation: let operation, rs2: let rs2)):
				return .registerRegister(operation: operation, rd: destination, rs1: rs1, rs2: rs2)
				
				case .assign(destination: let destination, value: .registerImmediate(rs1: let rs1, operation: let operation, imm: let imm)):
				return .registerImmediate(operation: operation, rd: destination, rs1: rs1, imm: imm)
				
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
	.assign(destination: rd, value: value)
}

public func <- (rd: FL.Register, imm: Int) -> FL.Instruction {
	rd <- FL.Register.zero + imm
}

public func <- (rd: FL.Register, rs: FL.Register) -> FL.Instruction {
	.copy(.word, destination: rd, source: rs)
}

public func <= (rd: FL.Register, rs: FL.Register) -> FL.Instruction {
	.copy(.capability, destination: rd, source: rs)
}

public func <- (rd: FL.Register, src: FL.FrameCellLocation) -> FL.Instruction {
	.load(.word, destination: rd, source: src)
}

public func <= (rd: FL.Register, src: FL.FrameCellLocation) -> FL.Instruction {
	.load(.capability, destination: rd, source: src)
}

public func <- (dest: FL.FrameCellLocation, src: FL.Register) -> FL.Instruction {
	.store(.word, destination: dest, source: src)
}

public func <= (dest: FL.FrameCellLocation, src: FL.Register) -> FL.Instruction {
	.store(.capability, destination: dest, source: src)
}
