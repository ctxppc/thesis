// Glyco © 2021–2022 Constantino Tsarouhas

extension FL {
	
	/// An effect on an FL machine.
	public enum Effect : Codable, Equatable, MultiplyLowerable {
		
		/// An effect that copies the contents from `source` to `destination`.
		case copy(DataType, destination: Register, source: Register)
		
		/// An effect that computes `value` and puts the result in `rd`.
		case compute(destination: Register, value: BinaryExpression)
		
		/// An effect that loads the datum at the address in `rs1`, offset by `imm`, and puts it in `rd`.
		case load(DataType, destination: Register, source: Frame.Location)
		
		/// An effect that retrieves the datum from `source` and stores it in `destination`.
		case store(DataType, destination: Frame.Location, source: Register)
		
		/// An effect that jumps to `to` if *x* `relation` *y*, where *x* is the value in `rs1` and *y* is the value in `rs2`.
		case branch(to: Label, Register, BranchRelation, Register)
		
		/// An effect that jumps to `to`.
		case jump(to: Label)
		
		/// An effect that puts the next PCC in `cra`, then jumps to given label.
		case call(Label)
		
		/// An effect that jumps to address *x*, where *x* is the value in `cra`.
		case `return`
		
		/// An effect that can jumped to using given label.
		indirect case labelled(Label, Effect)
		
		/// An effect that does nothing.
		static var nop: Self { .zero <- Register.zero + .zero }
		
		// See protocol.
		func lowered(in context: inout Frame) throws -> [Lower.Instruction] {
			switch self {
				
				case .copy(let type, destination: let destination, source: let source):
				return try [.copy(type, destination: destination.lowered(), source: source.lowered())]
				
				case .compute(destination: let destination, value: .registerRegister(let rs1, let operation, let rs2)):
				return try [.registerRegister(operation: operation, rd: destination.lowered(), rs1: rs1.lowered(), rs2: rs2.lowered())]
				
				case .compute(destination: let destination, value: .registerImmediate(let rs1, let operation, let imm)):
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
				
				case .branch(to: let target, let rs1, let relation, let rs2):
				return try [.branch(rs1: rs1.lowered(), relation: relation, rs2: rs2.lowered(), target: target)]
				
				case .jump(to: let target):
				return [.jump(target: target)]
				
				case .call(let label):
				return [.call(target: label)]
				
				case .return:
				return [.return]
				
				case .labelled(let label, let instruction):
				guard let (first, tail) = try instruction.lowered(in: &context).splittingFirst() else { return [] /* should never happen — famous last words */ }
				return [.labelled(label, first)].appending(contentsOf: tail)
				
			}
		}
		
	}
	
}

public func <- (rd: FL.Register, value: FL.BinaryExpression) -> FL.Effect {
	.compute(destination: rd, value: value)
}

public func <- (rd: FL.Register, imm: Int) -> FL.Effect {
	rd <- FL.Register.zero + imm
}

public func <- (rd: FL.Register, rs: FL.Register) -> FL.Effect {
	.copy(.word, destination: rd, source: rs)
}

public func <= (rd: FL.Register, rs: FL.Register) -> FL.Effect {
	.copy(.capability, destination: rd, source: rs)
}

public func <- (rd: FL.Register, src: FL.Frame.Location) -> FL.Effect {
	.load(.word, destination: rd, source: src)
}

public func <= (rd: FL.Register, src: FL.Frame.Location) -> FL.Effect {
	.load(.capability, destination: rd, source: src)
}

public func <- (dest: FL.Frame.Location, src: FL.Register) -> FL.Effect {
	.store(.word, destination: dest, source: src)
}

public func <= (dest: FL.Frame.Location, src: FL.Register) -> FL.Effect {
	.store(.capability, destination: dest, source: src)
}
