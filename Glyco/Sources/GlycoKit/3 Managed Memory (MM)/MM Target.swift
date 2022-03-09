// Glyco © 2021–2022 Constantino Tsarouhas

extension MM {
	
	/// A jump target.
	public enum Target : Codable, Equatable, SimplyLowerable {
		
		/// The jump target is labelled.
		case label(Label)
		
		/// The jump target is provided by a capability in given register.
		case register(Register)
		
		// See protocol.
		func lowered(in context: inout ()) throws -> Lower.Target {
			switch self {
				case .label(let label):			return .label(label)
				case .register(let register):	return .register(try register.lowered())
			}
		}
		
	}
	
}
