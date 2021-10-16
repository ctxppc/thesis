// Glyco © 2021 Constantino Tsarouhas

enum FL : Language {
	
	/// A program in the base language.
	struct Program : Codable, GlycoKit.Program {
		
		/// The program's instructions.
		var instructions: [Instruction] = []
		
		// See protocol.
		func lowered() -> Lower.Program {
			.init(instructions: instructions.map(\.rvInstruction))
		}
		
	}
	
	// See protocol.
	typealias Lower = RV
	
}
