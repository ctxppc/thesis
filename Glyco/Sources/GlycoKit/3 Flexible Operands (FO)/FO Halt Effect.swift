// Glyco © 2021–2022 Constantino Tsarouhas

extension FO {
	
	/// An FO effect where the machine halts execution of the program.
	public struct HaltEffect : Codable, Equatable, SimplyLowerable {
		
		/// The source of the result value.
		public var result: Source
		
		// See protocol.
		public func lowered(in context: inout ()) throws -> Lower.Instruction {
			switch result {
				case .immediate(let imm):				return .a0 <- imm
				case .location(.register(let result)):	return try .a0 <- result.lowered()
				case .location(.frameCell(let result)):	return .a0 <- result
			}
		}
		
	}
	
}
