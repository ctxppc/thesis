// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	/// A CHERI-RISC-V instruction.
	///
	/// These instructions map one to one to assembly instructions.
	public enum Instruction : Codable {
		
		/// An integral instruction.
		case integral(IntegralInstruction)
		
		/// A load instruction.
		case load(LoadInstruction)
		
		/// A store instruction.
		case store(StoreInstruction)
		
	}
	
}

extension FL.Instruction {
	
	/// The RV representation of `self`.
	public var rvInstruction: RV.Instruction {
		switch self {
			case .integral(let instruction):	return .integral(instruction.rvInstruction)
			case .load(let instruction):		return .load(instruction.rvInstruction)
			case .store(let instruction):		return .store(instruction.rvInstruction)
		}
	}
	
}
