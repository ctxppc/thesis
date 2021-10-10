// Glyco © 2021 Constantino Tsarouhas

/// An FO program.
struct FOProgram : Codable {
	
	/// The main effect of the program.
	var mainEffects: [FOEffect]
	
	/// The halt effect after executing `mainEffects`.
	var haltEffect: FOHaltEffect
	
}

extension FOProgram {
	
	/// The FL representation of `self`.
	var flProgram: FLProgram {
		.init(instructions: mainEffects.flatMap(\.flInstructions) + [haltEffect.flInstruction])
	}
	
}
