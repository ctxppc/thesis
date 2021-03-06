// Glyco © 2021–2022 Constantino Tsarouhas

import Sisp

extension NT {
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
		///
		/// The type must be a sealed capability type if `sealed` is `true`. The argument is unsealed on the callee-side.
		public var type: ValueType
		
		/// A Boolean value indicating whether an argument to `self` is sealed, to be unsealed by the sealed call.
		///
		/// At most one parameter in a procedure can be marked as sealed.
		@Defaulted<False>
		public var sealed: Bool
		
		// See protocol.
		func lowered(in context: inout LoweringContext) throws -> Lower.Parameter {
			.init(name, try type.lowered(in: &context), sealed: sealed)
		}
		
	}
}
