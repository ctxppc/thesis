// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	/// A CHERI-RISC-V instruction.
	///
	/// These instructions map one to one to assembly instructions.
	public enum Instruction : Codable, Equatable, MultiplyLowerable {
		
		/// An instruction that copies the contents from `source` to `destination`.
		case copy(DataType, destination: Register, source: Register)
		
		/// An instruction that computes `value` and puts the result in `rd`.
		case compute(destination: Register, value: BinaryExpression)
		
		/// An instruction that loads the datum at the address in `rs1`, offset by `imm`, and puts it in `rd`.
		case load(DataType, destination: Register, source: Frame.Location)
		
		/// An instruction that retrieves the datum from `source` and stores it in `destination`.
		case store(DataType, destination: Frame.Location, source: Register)
		
		/// An instruction that jumps to `target` if *x* `relation` *y*, where *x* is the value in `rs1` and *y* is the value in `rs2`.
		case branch(target: Label, rs1: Register, relation: BranchRelation, rs2: Register)
		
		/// An instruction that jumps to `target`.
		case jump(target: Label)
		
		/// An instruction that puts the next PCC in `cra`, then jumps to `target`.
		case call(target: Label)
		
		/// An instruction that jumps to address *x*, where *x* is the value in `cra`.
		case `return`
		
		/// An instruction that can jumped to using given label.
		indirect case labelled(Label, Instruction)
		
		/// An instruction that does nothing.
		static var nop: Self { .zero <- Register.zero + .zero }
		
		// See protocol.
		func lowered(in context: inout Frame) throws -> [Lower.Instruction] {
			switch self {
				
				case .copy(let type, destination: let destination, source: let source):
				return try [.copy(type, destination: destination.lowered(), source: source.lowered())]
				
				case .compute(destination: let destination, value: .registerRegister(rs1: let rs1, operation: let operation, rs2: let rs2)):
				return try [.registerRegister(operation: operation, rd: destination.lowered(), rs1: rs1.lowered(), rs2: rs2.lowered())]
				
				case .compute(destination: let destination, value: .registerImmediate(rs1: let rs1, operation: let operation, imm: let imm)):
				return try [.registerImmediate(operation: operation, rd: destination.lowered(), rs1: rs1.lowered(), imm: imm)]
				
				case .load(.word, destination: let destination, source: let source):
				return [
					.offsetCapability(destination: .t0, source: .fp, offset: source.offset),
					.loadWord(destination: try destination.lowered(), address: .t0)
				]
				
				case .load(.capability, destination: let destination, source: let source):
				return [.loadCapability(destination: try destination.lowered(), address: .fp, offset: source.offset)]
				
				case .store(.word, destination: let destination, source: let source):
				return [
					.offsetCapability(destination: .t0, source: .fp, offset: destination.offset),
					.storeWord(source: try source.lowered(), address: .t0)
				]
				
				case .store(.capability, destination: let destination, source: let source):
				return [.storeCapability(source: try source.lowered(), address: .fp, offset: destination.offset)]
				
				case .branch(target: let target, rs1: let rs1, relation: let relation, rs2: let rs2):
				return try [.branch(rs1: rs1.lowered(), relation: relation, rs2: rs2.lowered(), target: target)]
				
				case .jump(target: let target):
				return [.jump(target: target)]
				
				case .call(target: let label):
				return [.call(target: label)]
				
				case .return:
				return [.return]
				
				case .labelled(let label, let instruction):
				guard let (first, tail) = try instruction.lowered(in: &context).splittingFirst() else { return [] /* should never happen — famous last words */ }
				return [.labelled(label, first)].appending(contentsOf: tail)
				
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

public func <- (rd: FL.Register, src: FL.Frame.Location) -> FL.Instruction {
	.load(.word, destination: rd, source: src)
}

public func <= (rd: FL.Register, src: FL.Frame.Location) -> FL.Instruction {
	.load(.capability, destination: rd, source: src)
}

public func <- (dest: FL.Frame.Location, src: FL.Register) -> FL.Instruction {
	.store(.word, destination: dest, source: src)
}

public func <= (dest: FL.Frame.Location, src: FL.Register) -> FL.Instruction {
	.store(.capability, destination: dest, source: src)
}
