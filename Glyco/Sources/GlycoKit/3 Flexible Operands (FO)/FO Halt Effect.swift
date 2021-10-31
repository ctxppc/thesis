// Glyco © 2021 Constantino Tsarouhas

extension FO {
	
	/// An FO effect where the machine halts execution of the program.
	public struct HaltEffect : Codable {
		
		/// The source of the result value.
		public var result: Source
		
		/// Returns a representation of `self` in a lower language.
		public func lowered() -> Lower.Instruction {
			switch result {
				case .immediate(let imm):				return .a0 <- imm
				case .location(.register(let result)):	return .a0 <- result.lowered()
				case .location(.frameCell(let result)):	return .a0 <- result
			}
		}
		
	}
	
}
