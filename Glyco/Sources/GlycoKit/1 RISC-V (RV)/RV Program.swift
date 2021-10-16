// Glyco © 2021 Constantino Tsarouhas

enum RV {
	
	/// A program in the base language.
	struct Program : Codable {
		
		/// The program's instructions.
		var instructions: [Instruction] = []
		
	}
	
}

extension RV.Program {
	
	/// The assembly representation of `self`.
	var assembly: String {
		// TODO: Sections, entry points, etc.
		instructions
			.map(\.assembly)
			.joined(separator: "\n")
	}
	
}
