// Glyco © 2021 Constantino Tsarouhas

/// An FO effect where the machine halts execution of the program.
struct FOHaltEffect : Codable {
	
	/// The source of the result value.
	var result: FOSource
	
}

extension FOHaltEffect {
	
	/// The FL instruction representing `self`.
	var flInstruction: FLInstruction {
		switch result {
			case .immediate(let imm):				return .integral(.a0 <- imm)
			case .location(.register(let result)):	return .integral(.a0 <- result)
			case .location(.frameCell(let result)):	return .load(.a0 <- result)
		}
	}
	
}
