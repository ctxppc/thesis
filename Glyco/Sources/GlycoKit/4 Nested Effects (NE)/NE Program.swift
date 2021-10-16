// Glyco © 2021 Constantino Tsarouhas

public enum NE : Language {
	
	/// A program on an NE machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// The main effect of the program.
		public var mainEffects: [Effect]
		
		/// The halt effect after executing `mainEffects`.
		public var haltEffect: HaltEffect
		
		// See protocol.
		public func lowered() -> Lower.Program {
			.init(mainEffects: mainEffects.flatMap { $0.lowered() }, haltEffect: haltEffect)
		}
		
	}
	
	// See protocol.
	public typealias Lower = FO
	
	public typealias HaltEffect = Lower.HaltEffect
	
}
