// Glyco © 2021 Constantino Tsarouhas

enum NE : Language {
	
	/// A program on an NE machine.
	struct Program : Codable, GlycoKit.Program {
		
		/// The main effect of the program.
		var mainEffects: [Effect]
		
		/// The halt effect after executing `mainEffects`.
		var haltEffect: HaltEffect
		
		// See protocol.
		func lowered() -> Lower.Program {
			.init(mainEffects: mainEffects.flatMap(\.foEffects), haltEffect: haltEffect)
		}
		
	}
	
	// See protocol.
	typealias Lower = FO
	
	typealias HaltEffect = Lower.HaltEffect
	
}
