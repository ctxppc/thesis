// Glyco © 2021 Constantino Tsarouhas

public enum AL : Language {
	
	/// A program on an AL machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// Creates a program with given effects.
		public init(effects: [Effect]) {
			self.effects = effects
		}
		
		/// The effects of the program.
		public var effects: [Effect]
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) -> Lower.Program {
			var context = Lower.Context()
			let homes = Dictionary(uniqueKeysWithValues: accessedLocations().map { ($0, Lower.Location.frameCell(.allocate(.word, context: &context))) })
			TODO.unimplemented
		}
		
		/// Returns a set of locations (potentially) accessed by `self`.
		public func accessedLocations() -> Set<Location> {
			Set(effects.lazy.flatMap { $0.accessedLocations() })
		}
		
	}
	
	// See protocol.
	public typealias Lower = BB
	
}
