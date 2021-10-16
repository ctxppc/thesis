// Glyco © 2021 Constantino Tsarouhas

enum FO {
	
	/// An FO program.
	struct Program : Codable {
		
		/// The main effect of the program.
		var mainEffects: [Effect]
		
		/// The halt effect after executing `mainEffects`.
		var haltEffect: HaltEffect
		
	}
	
}

extension FO.Program {
	
	/// The FL representation of `self`.
	var flProgram: FL.Program {
		.init(instructions: mainEffects.flatMap(\.flInstructions) + [haltEffect.flInstruction])
	}
	
}
