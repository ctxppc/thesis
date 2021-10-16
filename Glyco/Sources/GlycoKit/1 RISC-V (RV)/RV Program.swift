// Glyco © 2021 Constantino Tsarouhas

public enum RV : Language {
	
	/// A program in the base language.
	public struct Program : Codable, GlycoKit.Program {
		
		/// The program's instructions.
		public var instructions: [Instruction] = []
		
		// See protocol.
		public func lowered() -> Never {
			fatalError("Cannot lower RV to another language; use `assembly()` to retrieve the program‘s assembly representation.")
		}
		
		// See protocol.
		public func compiled() -> String {
			// TODO: Sections, entry points, etc.
			instructions
				.map(\.assembly)
				.joined(separator: "\n")
		}
		
	}
	
	// See protocol.
	public typealias Lower = Never
	
}
