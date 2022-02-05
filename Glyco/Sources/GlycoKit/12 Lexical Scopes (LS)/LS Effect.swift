// Glyco © 2021–2022 Constantino Tsarouhas

extension LS {
	
	/// An effect on an LS machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs given effects.
		case `do`([Effect])
		
		/// An effect that performs given effect after associating zero or more values with a name.
		indirect case `let`([Definition], in: Effect)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(of: Symbol, at: Source, to: Source)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects):
				return .do(try effects.lowered(in: &context))
				
				case .let(let definitions, in: let effect):
				return try .let(definitions.lowered(in: &context), in: effect.lowered(in: &context))
				
				case .setElement(of: let vector, at: let index, to: let element):
				return try .setElement(of: vector.lowered(in: &context), at: index.lowered(in: &context), to: element.lowered(in: &context))
				
			}
		}
		
	}
	
}
