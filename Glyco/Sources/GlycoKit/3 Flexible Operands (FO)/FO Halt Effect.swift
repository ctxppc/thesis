// Glyco © 2021 Constantino Tsarouhas

extension FO {
	
	/// An FO effect where the machine halts execution of the program.
	struct HaltEffect : Codable {
		
		/// The source of the result value.
		var result: Source
		
	}
	
}

extension FO.HaltEffect {
	
	/// The FL instruction representing `self`.
	var flInstruction: FL.Instruction {
		switch result {
			case .immediate(let imm):				return .integral(.a0 <- imm)
			case .location(.register(let result)):	return .integral(.a0 <- result)
			case .location(.frameCell(let result)):	return .load(.a0 <- result)
		}
	}
	
}
