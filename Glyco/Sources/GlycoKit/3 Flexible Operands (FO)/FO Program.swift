// Glyco © 2021 Constantino Tsarouhas

public enum FO : Language {
	
	/// An FO program.
	public struct Program : Codable, GlycoKit.Program {
		
		/// The main effect of the program.
		public var mainEffects: [Effect]
		
		/// The halt effect after executing `mainEffects`.
		public var haltEffect: HaltEffect
		
		// See protocol.
		public func lowered() -> Lower.Program {
			.init(instructions: mainEffects.flatMap(\.flInstructions) + [haltEffect.flInstruction])
		}
		
	}
	
	// See protocol.
	public typealias Lower = FL
	
}
