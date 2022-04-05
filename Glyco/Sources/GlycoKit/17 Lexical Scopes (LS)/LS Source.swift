// Glyco © 2021–2022 Constantino Tsarouhas

extension LS {
	
	/// A datum source.
	public enum Source : Codable, Equatable, SimplyLowerable {
		
		/// An integer with given value.
		case constant(Int)
		
		/// The value bound to given name.
		case named(Symbol)
		
		/// A capability pointing to given labelled procedure.
		case procedure(Label)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Source {
			switch self {
				case .constant(let value):	return .constant(value)
				case .named(let symbol):	return .location(try symbol.lowered(in: &context))
				case .procedure(let name):	return .procedure(name)
			}
		}
		
	}
	
}
