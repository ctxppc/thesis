// Glyco © 2021 Constantino Tsarouhas

/// A program on an AL machine.
struct ALProgram : Codable {
	
	/// The main effect of the program.
	var mainEffects: [ALEffect]
	
	/// The halt effect after executing `mainEffects`.
	var haltEffect: ALHaltEffect
	
}

extension ALProgram {
	
	/// Returns a set of locations (potentially) accessed by `self`.
	func accessedLocations() -> Set<ALLocation> {
		haltEffect.accessedLocations().union(mainEffects.lazy.flatMap { $0.accessedLocations() })
	}
	
	/// Returns a NE representation of `self`.
	func neProgram() -> NEProgram {
		let homes = Dictionary(uniqueKeysWithValues: accessedLocations().map { ($0, NELocation.frameCell(.allocate())) })
		return .init(mainEffects: mainEffects.map { $0.neEffect(homes: homes) }, haltEffect: haltEffect.neEffect(homes: homes))
	}
	
}
