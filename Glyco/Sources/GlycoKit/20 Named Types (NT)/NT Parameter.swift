// Glyco © 2021–2022 Constantino Tsarouhas

extension NT {
	public struct Parameter : Codable, Equatable, SimplyLowerable {
		
		public init(_ name: Symbol, _ type: ValueType) {
			self.name = name
			self.type = type
		}
		
		/// The name of the actual parameter.
		public let name: Symbol
		
		/// The data type of the argument.
		public let type: ValueType
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Parameter {
			.init(name, try type.lowered(in: &context))
		}
		
	}
}
