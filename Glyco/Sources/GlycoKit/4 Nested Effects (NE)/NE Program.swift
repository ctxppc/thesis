// Glyco © 2021 Constantino Tsarouhas

enum NE {
	
	/// A program on an NE machine.
	struct Program : Codable {
		
		/// The main effect of the program.
		var mainEffects: [Effect]
		
		/// The halt effect after executing `mainEffects`.
		var haltEffect: HaltEffect
		
	}
	
	typealias HaltEffect = FO.HaltEffect
	
}

extension NE.Program {
	
	/// The FO representation of `self`.
	var foProgram: FO.Program {
		.init(mainEffects: mainEffects.flatMap(\.foEffects), haltEffect: haltEffect)
	}
	
}
