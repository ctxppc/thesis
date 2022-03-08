// Glyco © 2021–2022 Constantino Tsarouhas

extension CE {
	
	/// A datum source.
	public enum Source : Codable, Equatable {
		
		/// The operand is given value.
		case constant(Int)
		
		/// The operand is a value in given register.
		case register(Register)
		
	}
	
}
