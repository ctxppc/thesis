// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	/// A CHERI-RISC-V instruction.
	///
	/// These instructions map one to one to assembly instructions.
	public enum Instruction : Codable {
		
		/// An instruction that copies the contents from `source` to `destination`.
		case copy(DataType, destination: Register, source: Register)
		
		/// An instruction that computes `value` and puts the result in `rd`.
		case compute(destination: Register, value: BinaryExpression)
		
		/// An instruction that loads the datum at the address in `rs1`, offset by `imm`, and puts it in `rd`.
		case load(DataType, destination: Register, source: FrameCellLocation)
		
		/// An instruction that retrieves the datum from `source` and stores it in `destination`.
		case store(DataType, destination: FrameCellLocation, source: Register)
		
		/// An instruction that jumps to `target` if *x* `relation` *y*, where *x* is the value in `rs1` and *y* is the value in `rs2`.
		case branch(target: Label, rs1: Register, relation: BranchRelation, rs2: Register)
		
		/// An instruction that puts the PCC in `cd` then jumps to address *x*, where *x* is the value in `cs1`.
		case jump(cd: Register, cs1: Register)
		
		/// An instruction that can jumped to using given label.
		indirect case labelled(Label, Instruction)
		
		/// An instruction that does nothing.
		static var nop: Self { .zero <- Register.zero + .zero }
		
		/// Returns a representation of `self` in a lower language.
		func lowered(context: inout Context) -> Lower.Instruction {
			switch self {
				
				case .copy(let type, destination: let destination, source: let source):
				return .copy(type, destination: destination, source: source)
				
				case .compute(destination: let destination, value: .registerRegister(rs1: let rs1, operation: let operation, rs2: let rs2)):
				return .registerRegister(operation: operation, rd: destination, rs1: rs1, rs2: rs2)
				
				case .compute(destination: let destination, value: .registerImmediate(rs1: let rs1, operation: let operation, imm: let imm)):
				return .registerImmediate(operation: operation, rd: destination, rs1: rs1, imm: imm)
				
				case .load(let type, destination: let destination, source: let source):
				return .load(type, destination: destination, address: .fp, offset: source.offset)
				
				case .store(let type, destination: let destination, source: let source):
				return .store(type, source: source, address: .fp, offset: destination.offset)
				
				case .branch(target: let target, rs1: let rs1, relation: let relation, rs2: let rs2):
				return .branch(rs1: rs1, relation: relation, rs2: rs2, target: target)
				
				case .jump(cd: let cd, cs1: let cs1):
				return .jump(cd: cd, cs1: cs1)
				
				case .labelled(let label, let instruction):
				return .labelled(label, instruction.lowered(context: &context))
				
			}
		}
		
	}
	
	public typealias DataType = Lower.DataType
	public typealias Label = Lower.Label
	public typealias BranchRelation = Lower.BranchRelation
	
}

public func <- (rd: FL.Register, value: FL.BinaryExpression) -> FL.Instruction {
	.compute(destination: rd, value: value)
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
