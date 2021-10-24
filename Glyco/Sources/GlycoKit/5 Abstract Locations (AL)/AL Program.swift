// Glyco © 2021 Constantino Tsarouhas

public enum AL : Language {
	
	/// A program on an AL machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// Creates a program with given effects.
		public init(mainEffects: [Effect], haltEffect: HaltEffect) {
			self.mainEffects = mainEffects
			self.haltEffect = haltEffect
		}
		
		/// The main effect of the program.
		public var mainEffects: [Effect]
		
		/// The halt effect after executing `mainEffects`.
		public var haltEffect: HaltEffect
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) -> Lower.Program {
			var context = Lower.Context()
			let homes = Dictionary(uniqueKeysWithValues: accessedLocations().map { ($0, Lower.Location.frameCell(.allocate(context: &context))) })
			return .init(mainEffects: mainEffects.map { $0.lowered(homes: homes) }, haltEffect: haltEffect.lowered(homes: homes))
		}
		
		/// Returns a set of locations (potentially) accessed by `self`.
		public func accessedLocations() -> Set<Location> {
			haltEffect.accessedLocations().union(mainEffects.lazy.flatMap { $0.accessedLocations() })
		}
		
	}
	
	// See protocol.
	public typealias Lower = NE
	
}
