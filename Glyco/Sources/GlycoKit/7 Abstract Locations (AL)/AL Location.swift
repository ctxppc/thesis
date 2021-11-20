// Glyco © 2021 Constantino Tsarouhas

extension AL {
	
	/// A storage location on an AL machine.
	public enum Location : Codable, Hashable, SimplyLowerable {
		
		/// A location that is to be assigned a physical location.
		case abstract(AbstractLocation)
		
		/// A location on the frame.
		case frameLocation(Frame.Location)
		
		/// A parameter register.
		case parameterRegister(ParameterRegister)
		
		// See protocol.
		func lowered(in context: inout Context) -> Lower.Location {
			switch self {
				case .abstract(let location):			return context.assignments[location]
				case .frameLocation(let location):		return .frameCell(location)
				case .parameterRegister(let register):	return .register(register.lowered(in: &context))
			}
		}
		
	}
	
}
