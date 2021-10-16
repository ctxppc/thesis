// Glyco © 2021 Constantino Tsarouhas

enum FL {
	
	/// A program in the base language.
	struct Program : Codable {
		
		/// The program's instructions.
		var instructions: [Instruction] = []
		
	}
	
}

extension FL.Program {
	
	/// The RV representation of `self`.
	var rvProgram: RV.Program {
		.init(instructions: instructions.map(\.rvInstruction))
	}
	
}
