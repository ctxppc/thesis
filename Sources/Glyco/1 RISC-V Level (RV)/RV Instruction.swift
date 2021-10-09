// Glyco © 2021 Constantino Tsarouhas

/// A CHERI-RISC-V instruction.
///
/// These instructions map one to one to assembly instructions.
enum RVInstruction : Codable {
	
	/// An integer instruction.
	case integer(RVIntegerInstruction)
	
}

extension RVInstruction {
	
	var assembly: String {
		switch self {
			case .integer(let instruction):	return instruction.assembly
		}
	}
	
}
