// Glyco © 2021 Constantino Tsarouhas

enum AL : Language {
	
	/// A program on an AL machine.
	struct Program : Codable, GlycoKit.Program {
		
		/// The main effect of the program.
		var mainEffects: [Effect]
		
		/// The halt effect after executing `mainEffects`.
		var haltEffect: HaltEffect
		
		// See protocol.
		func lowered() -> Lower.Program {
			let homes = Dictionary(uniqueKeysWithValues: accessedLocations().map { ($0, NE.Location.frameCell(.allocate())) })
			return .init(mainEffects: mainEffects.map { $0.neEffect(homes: homes) }, haltEffect: haltEffect.neEffect(homes: homes))
		}
		
		/// Returns a set of locations (potentially) accessed by `self`.
		func accessedLocations() -> Set<AL.Location> {
			haltEffect.accessedLocations().union(mainEffects.lazy.flatMap { $0.accessedLocations() })
		}
		
	}
	
	// See protocol.
	typealias Lower = NE
	
}
