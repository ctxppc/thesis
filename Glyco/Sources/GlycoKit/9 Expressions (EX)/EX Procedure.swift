// Glyco © 2021 Constantino Tsarouhas

extension EX {
	
	/// A program element that can be invoked by name.
	public enum Procedure : Codable, Equatable, SimplyLowerable {
		
		/// A procedure with given name, parameters, and body.
		case procedure(Label, parameters: [Parameter] = [], Statement)
		public typealias Parameter = Lower.Procedure.Parameter
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Procedure {
			switch self {
				case .procedure(let name, parameters: let parameters, let body):
				return .init(name: name, parameters: parameters, effect: try body.lowered(in: &context))
			}
		}
		
	}
	
}
