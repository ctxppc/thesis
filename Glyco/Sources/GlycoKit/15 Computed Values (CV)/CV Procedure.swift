// Glyco © 2021–2022 Constantino Tsarouhas

extension CV {
	
	/// A program element that can be invoked by name.
	public struct Procedure : SimplyLowerable, Element {
		
		/// Creates a procedure with given name, parameters, result type, and effect.
		public init(_ name: Label, takes parameters: [Parameter], returns resultType: ValueType, in effect: Effect) {
			self.name = name
			self.parameters = parameters
			self.resultType = resultType
			self.effect = effect
		}
		
		/// The name with which the procedure can be invoked.
		public var name: Label
		
		/// The procedure's parameters.
		public var parameters: [Parameter]
		
		/// The procedure's result type.
		public var resultType: ValueType
		
		/// The procedure's effect when invoked.
		public var effect: Effect
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Procedure {
			.init(name, takes: parameters, returns: resultType, in: try effect.lowered(in: &context))
		}
		
	}
	
}
