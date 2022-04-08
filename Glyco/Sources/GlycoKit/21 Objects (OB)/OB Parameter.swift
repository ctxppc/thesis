// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
	public struct Parameter : Codable, Equatable, SimplyLowerable {
		
		/// Creates a parameter with given name and value type.
		public init(_ name: Symbol, _ type: ValueType) {
			self.name = name
			self.type = type
		}
		
		/// The name of the actual parameter.
		public var name: Symbol
		
		/// The data type of the argument.
		public var type: ValueType
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Parameter {
			.init(name, try type.lowered(in: &context), sealed: false)
		}
		
	}
}
