// Glyco © 2021 Constantino Tsarouhas

extension AL {
	
	/// A machine register that can be used to pass arguments to a procedure.
	public enum ParameterRegister : String, Codable, Hashable, CaseIterable, SimplyLowerable {
		
		/// An argument or return value register.
		case a0, a1
		
		/// An argument register.
		case a2, a3, a4, a5, a6, a7
		
		// See protocol.
		func lowered(in context: inout Context) -> Lower.Register {
			switch self {
				case .a0:	return .a0
				case .a1:	return .a1
				case .a2:	return .a2
				case .a3:	return .a3
				case .a4:	return .a4
				case .a5:	return .a5
				case .a6:	return .a6
				case .a7:	return .a7
			}
		}
		
	}
	
}
