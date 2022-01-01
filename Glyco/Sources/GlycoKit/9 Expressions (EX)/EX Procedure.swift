// Glyco © 2021–2022 Constantino Tsarouhas

extension EX {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, SimplyLowerable {
		
		/// The name with which the procedure can be invoked.
		var name: Label
		
		/// The procedure's parameters.
		var parameters: [Parameter] = []
		public typealias Parameter = Lower.Procedure.Parameter
		
		/// The statement executed when the procedure is invoked.
		var body: Statement
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Procedure {
			.init(name: name, parameters: parameters, effect: try body.lowered(in: &context))
		}
		
		// See protocol.
		public enum CodingKeys : String, CodingKey {
			case name = "_0"
			case parameters = "_1"
			case body = "_2"
		}
		
	}
	
}
