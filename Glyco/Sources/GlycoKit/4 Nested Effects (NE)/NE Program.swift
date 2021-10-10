// Glyco © 2021 Constantino Tsarouhas

/// A program on a NE machine.
struct NEProgram : Codable {
	
	/// The main effect of the program.
	var mainEffects: [NEEffect]
	
	/// The halt effect after executing `mainEffects`.
	var haltEffect: FOHaltEffect
	
}

extension NEProgram {
	
	/// The FO representation of `self`.
	var foProgram: FOProgram {
		.init(mainEffects: mainEffects.flatMap(\.foEffects), haltEffect: haltEffect)
	}
	
}
