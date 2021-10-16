// Glyco © 2021 Constantino Tsarouhas

enum AL {
	
	/// A program on an AL machine.
	struct Program : Codable {
		
		/// The main effect of the program.
		var mainEffects: [Effect]
		
		/// The halt effect after executing `mainEffects`.
		var haltEffect: HaltEffect
		
	}
	
}

extension AL.Program {
	
	/// Returns a set of locations (potentially) accessed by `self`.
	func accessedLocations() -> Set<AL.Location> {
		haltEffect.accessedLocations().union(mainEffects.lazy.flatMap { $0.accessedLocations() })
	}
	
	/// Returns a NE representation of `self`.
	func neProgram() -> NE.Program {
		let homes = Dictionary(uniqueKeysWithValues: accessedLocations().map { ($0, NE.Location.frameCell(.allocate())) })
		return .init(mainEffects: mainEffects.map { $0.neEffect(homes: homes) }, haltEffect: haltEffect.neEffect(homes: homes))
	}
	
}
