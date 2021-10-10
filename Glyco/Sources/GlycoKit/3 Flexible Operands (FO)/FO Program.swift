// Glyco © 2021 Constantino Tsarouhas

/// An FO program.
enum FOProgram : Codable {
	
	/// A program executing `effect` then `tail`.
	indirect case cons(effect: FOEffect, tail: Self)
	
	/// A program stopping execution and producing as result the datum at `result`.
	case halt(result: FOSource)
	
}

extension FOProgram {
	
	/// The FL representation of `self`.
	var flProgram: FLProgram {
		.init(instructions:
			sequence(first: self) { program in
				switch program {
					case .cons(effect: _, tail: let tail):	return tail
					case .halt:								return nil
				}
			}.flatMap { program -> [FLInstruction] in
				switch program {
					case .cons(effect: let effect, tail: _):				return effect.flInstructions
					case .halt(result: .immediate(let imm)):				return [.integral(.a0 <- imm)]
					case .halt(result: .location(.register(let result))):	return [.integral(.a0 <- result)]
					case .halt(result: .location(.frameCell(let result))):	return [.load(.a0 <- result)]
				}
			}
		)
	}
	
}
