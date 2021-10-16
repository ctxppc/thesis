// Glyco © 2021 Constantino Tsarouhas

extension RV {
	
	/// A CHERI-RISC-V instruction.
	///
	/// These instructions map one to one to assembly instructions.
	enum Instruction : Codable {
		
		/// An integral instruction.
		case integral(IntegralInstruction)
		
		/// A load instruction.
		case load(LoadInstruction)
		
		/// A store instruction.
		case store(StoreInstruction)
		
	}
	
}

extension RV.Instruction {
	
	/// The assembly representation of `self`.
	var assembly: String {
		switch self {
			case .integral(let instruction):	return instruction.assembly
			case .load(let instruction):		return instruction.assembly
			case .store(let instruction):		return instruction.assembly
		}
	}
	
}
