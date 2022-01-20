// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// A location for parameters.
	public enum ParameterLocation : Codable, Hashable, Comparable, SimplyLowerable {
		
		case register(Register)
		case frame(Frame.Location)
		
		// See protocol.
		func lowered(in context: inout LocalContext) throws -> Lower.Location {
			switch self {
				case .register(let register):	return .register(try register.lowered())
				case .frame(let location):		return .frameCell(location)
			}
		}
		
	}
	
}
