// Glyco © 2021–2022 Constantino Tsarouhas

extension LS {
	public struct Parameter : SimplyLowerable, Element {
		
		/// Creates a parameter with given name and value type.
		public init(_ name: Symbol, _ type: ValueType, sealed: Bool) {
			self.name = name
			self.type = type
			self.sealed = sealed
		}
		
		/// The name of the actual parameter.
		public var name: Symbol
		
		/// The data type of the argument.
		public var type: ValueType
		
		/// A Boolean value indicating whether an argument to `self` is sealed, to be unsealed by the sealed call.
		///
		/// At most one parameter in a procedure can be marked as sealed.
		public var sealed: Bool
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Parameter {
			try .init(name.lowered(in: &context), type.lowered(in: &context), sealed: sealed)
		}
		
	}
}
