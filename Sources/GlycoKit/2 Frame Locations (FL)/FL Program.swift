// Glyco © 2021 Constantino Tsarouhas

/// A program in the base language.
struct FLProgram : Codable {
	
	/// The program's instructions.
	var instructions: [FLInstruction] = []
	
}

extension FLProgram {
	
	/// The RV representation of `self`.
	var rvProgram: RVProgram {
		.init(instructions: instructions.map(\.rvInstruction))
	}
	
}
