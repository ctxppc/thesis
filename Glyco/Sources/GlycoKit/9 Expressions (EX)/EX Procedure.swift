// Glyco © 2021–2022 Constantino Tsarouhas

extension EX {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, SimplyLowerable {
		
		public init(_ name: Label, _ parameters: [Parameter] = [], _ body: Statement) {
			self.name = name
			self.parameters = parameters
			self.body = body
		}
		
		/// The name with which the procedure can be invoked.
		public var name: Label
		
		/// The procedure's parameters.
		public var parameters: [Parameter] = []
		public typealias Parameter = Lower.Procedure.Parameter
		
		/// The statement executed when the procedure is invoked.
		public var body: Statement
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Procedure {
			.init(name, parameters, try body.lowered(in: &context))
		}
		
	}
	
}
