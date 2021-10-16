// Glyco © 2021 Constantino Tsarouhas

enum FO : Language {
	
	/// An FO program.
	struct Program : Codable, GlycoKit.Program {
		
		/// The main effect of the program.
		var mainEffects: [Effect]
		
		/// The halt effect after executing `mainEffects`.
		var haltEffect: HaltEffect
		
		// See protocol.
		func lowered() -> Lower.Program {
			.init(instructions: mainEffects.flatMap(\.flInstructions) + [haltEffect.flInstruction])
		}
		
	}
	
	// See protocol.
	typealias Lower = FL
	
}
