// Glyco © 2021 Constantino Tsarouhas

extension RV {
	
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
		
		/// A return instruction.
		case `return`
		
		/// Returns the assembly representation of `self`.
		public func compiled() -> String {
			switch self {
				case .integral(let instruction):	return instruction.compiled()
				case .load(let instruction):		return instruction.compiled()
				case .store(let instruction):		return instruction.compiled()
				case .return:						return "cret"
			}
		}
		
	}
	
}
