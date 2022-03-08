// Glyco © 2021–2022 Constantino Tsarouhas

extension CE {
	
	/// A jump target.
	public enum Target : Codable, Equatable {
		
		/// The jump target is labelled.
		case label(Label)
		
		/// The jump target is provided by a capability in given register.
		case register(Register)
		
	}
	
}
