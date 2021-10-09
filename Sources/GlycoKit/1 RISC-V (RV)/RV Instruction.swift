// Glyco © 2021 Constantino Tsarouhas

/// A CHERI-RISC-V instruction.
///
/// These instructions map one to one to assembly instructions.
enum RVInstruction : Codable {
	
	/// An integral instruction.
	case integral(RVIntegralInstruction)
	
	/// A load instruction.
	case load(RVLoadInstruction)
	
}

extension RVInstruction {
	
	var assembly: String {
		switch self {
			case .integral(let instruction):	return instruction.assembly
			case .load(let instruction):		return instruction.assembly
		}
	}
	
}
