// Glyco © 2021 Constantino Tsarouhas

/// A CHERI-RISC-V instruction.
///
/// These instructions map one to one to assembly instructions.
enum FLInstruction : Codable {
	
	/// An integral instruction.
	case integral(FLIntegralInstruction)
	
	/// A load instruction.
	case load(FLLoadInstruction)
	
	/// A store instruction.
	case store(FLStoreInstruction)
	
}

extension FLInstruction {
	
	/// The RV representation of `self`.
	var rvInstruction: RVInstruction {
		switch self {
			case .integral(let instruction):	return .integral(instruction.rvInstruction)
			case .load(let instruction):		return .load(instruction.rvInstruction)
			case .store(let instruction):		return .store(instruction.rvInstruction)
		}
	}
	
}
