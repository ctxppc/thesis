// Glyco © 2021 Constantino Tsarouhas

/// A program in the base language.
struct RVProgram : Codable {
	
	/// The program's instructions.
	var instructions: [RVInstruction] = []
	
}

extension RVProgram {
	
	/// The assembly representation of `self`.
	var assembly: String {
		// TODO: Sections, entry points, etc.
		instructions
			.map(\.assembly)
			.joined(separator: "\n")
	}
	
}
