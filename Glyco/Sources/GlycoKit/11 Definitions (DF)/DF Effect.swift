// Glyco © 2021–2022 Constantino Tsarouhas

extension DF {
	
	/// An effect on a DF machine.
	public enum Effect : ComposableEffect, Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs given effects.
		case `do`([Effect])
		
		/// An effect that performs given effect after associating zero or more values with a name.
		indirect case `let`([Definition], in: Effect)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(of: Location, at: Source, to: Source)
		
		// See protocol.
		@EffectBuilder<Lowered>
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects):
				Lowered.do(try effects.lowered(in: &context))
				
				case .let(let definitions, in: let effect):
				try Lowered.do(definitions.lowered(in: &context))
				try effect.lowered(in: &context)
				
				case .setElement(of: let vector, at: let index, to: let element):
				Lowered.setElement(of: vector, at: index, to: element)
				
			}
		}
		
		// See protocol.
		var subeffects: [Self]? {
			guard case .do(let subeffects) = self else { return nil }
			return subeffects
		}
		
	}
	
}
