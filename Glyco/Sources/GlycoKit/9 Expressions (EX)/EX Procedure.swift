// Glyco © 2021 Constantino Tsarouhas

extension EX {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, SimplyLowerable {
		
		/// Creates a procedure with given name and body.
		public init(name: Label, body: Statement, parameters: [Parameter]) {
			self.name = name
			self.body = body
			self.parameters = parameters
		}
		
		/// The name with which the procedure can be invoked.
		public var name: Label
		
		/// The procedure's body.
		public var body: Statement
		
		/// The procedure's parameters.
		public var parameters: [Parameter]
		public typealias Parameter = Lower.Procedure.Parameter
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Procedure {
			.init(name: name, effect: try body.lowered(in: &context), parameters: parameters)
		}
		
	}
	
}
