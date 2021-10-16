// Glyco © 2021 Constantino Tsarouhas

public enum FL : Language {
	
	/// A program in the base language.
	public struct Program : Codable, GlycoKit.Program {
		
		/// The program's instructions.
		public var instructions: [Instruction] = []
		
		// See protocol.
		public func lowered() -> Lower.Program {
			.init(instructions: instructions.map { $0.lowered() })
		}
		
	}
	
	// See protocol.
	public typealias Lower = RV
	
}
