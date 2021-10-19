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
		
		/// Returns a representation of `self` in a lower language.
		func lowered(context: inout Context) -> Lower.Instruction {
			switch self {
				case .integral(let instruction):	return .integral(instruction.lowered(context: &context))
				case .load(let instruction):		return .load(instruction.lowered(context: &context))
				case .store(let instruction):		return .store(instruction.lowered(context: &context))
			}
		}
		
	}
	
}
