// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// A location.
	public enum Location : Codable, Hashable, Comparable, SimplyLowerable {
		
		case abstract(AbstractLocation)
		case parameter(ParameterLocation)
		
		// See protocol.
		func lowered(in context: inout LocalContext) throws -> Lower.Location {
			switch self {
				case .abstract(let location):	return location.lowered(in: &context)
				case .parameter(let location):	return try location.lowered(in: &context)
			}
		}
		
	}
	
}
