// Glyco © 2021–2022 Constantino Tsarouhas

extension NT {
	
	/// A named value.
	public struct Definition : Codable, Equatable, SimplyLowerable {
		
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
		func lowered(in context: inout LoweringContext) throws -> Lower.Definition {
			.init(name, try value.lowered(in: &context))
		}
		
	}
	
}

func ~(name: NT.Symbol, value: NT.Value) -> NT.Definition {
	.init(name, value)
}

extension Array where Element == NT.Definition {
	init(@ArrayBuilder<Element> _ elements: () throws -> Self) rethrows {
		self = try elements()
	}
}
