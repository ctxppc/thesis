// Glyco © 2021–2022 Constantino Tsarouhas

extension EX {
	
	/// A named value.
	public struct Definition : SimplyLowerable, Element {
		
		/// Creates a definition with given name and value.
		public init(_ name: Symbol, _ value: Value) {
			self.name = name
			self.value = value
		}
		
		/// The definition's name.
		public var name: Symbol
		
		/// The definition's value.
		public var value: Value
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Definition {
			let loweredValue = try value.lowered(in: &context)	// Lower the value in the previous scope.
			context.declare(name, try value.type(in: context))	// Enlarge scope.
			return .init(name, loweredValue)
		}
		
	}
	
}
