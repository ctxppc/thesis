// Glyco © 2021 Constantino Tsarouhas

/// A program on an NE machine.
struct NEProgram : Codable {
	
	/// The main effect of the program.
	var mainEffects: [NEEffect]
	
	/// The halt effect after executing `mainEffects`.
	var haltEffect: NEHaltEffect
	
}

typealias NEHaltEffect = FOHaltEffect

extension NEProgram {
	
	/// The FO representation of `self`.
	var foProgram: FOProgram {
		.init(mainEffects: mainEffects.flatMap(\.foEffects), haltEffect: haltEffect)
	}
	
}
