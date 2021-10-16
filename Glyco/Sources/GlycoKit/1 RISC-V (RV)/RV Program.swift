// Glyco © 2021 Constantino Tsarouhas

enum RV : Language {
	
	/// A program in the base language.
	struct Program : Codable, GlycoKit.Program {
		
		/// The program's instructions.
		var instructions: [Instruction] = []
		
		// See protocol.
		func lowered() -> Never {
			fatalError("Cannot lower RV to another language; use `assembly()` to retrieve the program‘s assembly representation.")
		}
		
		// See protocol.
		func compiled() -> String {
			// TODO: Sections, entry points, etc.
			instructions
				.map(\.assembly)
				.joined(separator: "\n")
		}
		
	}
	
	// See protocol.
	typealias Lower = Never
	
}
