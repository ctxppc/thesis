// Glyco © 2021–2022 Constantino Tsarouhas

extension FL {
	
	/// An effect on an FL machine.
	public enum Effect : Codable, Equatable, MultiplyLowerable {
		
		/// An effect that copies the contents from `from` to `into`.
		case copy(DataType, into: Register, from: Register)
		
		/// An effect that computes `value` and puts the result in `into`.
		case compute(into: Register, value: BinaryExpression)
		
		/// An effect that loads the datum in the frame at `from` and puts it in `into`.
		case load(DataType, into: Register, from: Frame.Location)
		
		/// An effect that retrieves the datum from `from` and stores it in the frame at `into`.
		case store(DataType, into: Frame.Location, from: Register)
		
		/// An effect that loads the element of the vector at `vector` at the zero-based position in `index` and puts it in `into`.
		case loadElement(DataType, into: Register, vector: Register, index: Register)
		
		/// An effect that retrieves the datum from `from` and stores it as an element of the vector at `vector` at the zero-based position in `index`.
		case storeElement(DataType, vector: Register, index: Register, from: Register)
		
		/// An effect that jumps to `to` if *x* *R* *y*, where *x* and *y* are given registers and *R* is given relation.
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
				
				case .copy(let type, into: let destination, from: let source):
				return try [.copy(type, destination: destination.lowered(), source: source.lowered())]
				
				case .compute(into: let destination, value: .registerRegister(let rs1, let operation, let rs2)):
				return try [.registerRegister(operation: operation, rd: destination.lowered(), rs1: rs1.lowered(), rs2: rs2.lowered())]
				
				case .compute(into: let destination, value: .registerImmediate(let rs1, let operation, let imm)):
				return try [.registerImmediate(operation: operation, rd: destination.lowered(), rs1: rs1.lowered(), imm: imm)]
				
				case .load(.word, into: let destination, from: let source):
				return [
					.offsetCapability(destination: .t0, source: .fp, offset: source.offset),
					.loadWord(destination: try destination.lowered(), address: .t0)
				]
				
				case .load(.capability, into: let destination, from: let source):
				return [.loadCapability(destination: try destination.lowered(), address: .fp, offset: source.offset)]
				
				case .store(.word, into: let destination, from: let source):
				return [
					.offsetCapability(destination: .t0, source: .fp, offset: destination.offset),
					.storeWord(source: try source.lowered(), address: .t0)
				]
				
				case .store(.capability, into: let destination, from: let source):
				return [.storeCapability(source: try source.lowered(), address: .fp, offset: destination.offset)]
				
				case .loadElement(.word, into: let destination, vector: let vector, index: let index):
				TODO.unimplemented
				
				case .loadElement(.capability, into: let destination, vector: let vector, index: let index):
				TODO.unimplemented
				
				case .storeElement(.word, vector: let vector, index: let index, from: let source):
				TODO.unimplemented
				
				case .storeElement(.capability, vector: let vector, index: let index, from: let source):
				TODO.unimplemented
				
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
	.compute(into: rd, value: value)
}

public func <- (rd: FL.Register, imm: Int) -> FL.Effect {
	rd <- FL.Register.zero + imm
}

public func <- (rd: FL.Register, rs: FL.Register) -> FL.Effect {
	.copy(.word, into: rd, from: rs)
}

public func <= (rd: FL.Register, rs: FL.Register) -> FL.Effect {
	.copy(.capability, into: rd, from: rs)
}

public func <- (rd: FL.Register, src: FL.Frame.Location) -> FL.Effect {
	.load(.word, into: rd, from: src)
}

public func <= (rd: FL.Register, src: FL.Frame.Location) -> FL.Effect {
	.load(.capability, into: rd, from: src)
}

public func <- (dest: FL.Frame.Location, src: FL.Register) -> FL.Effect {
	.store(.word, into: dest, from: src)
}

public func <= (dest: FL.Frame.Location, src: FL.Register) -> FL.Effect {
	.store(.capability, into: dest, from: src)
}
