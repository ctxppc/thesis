// Glyco © 2021–2022 Constantino Tsarouhas

extension EX {
	
	/// An effect on an EX machine.
	public enum Effect : ComposableEffect, Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs given effects.
		case `do`([Effect])
		
		/// An effect that performs given effect after associating zero or more values with a name.
		indirect case `let`([Definition], in: Effect)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(of: Value, at: Value, to: Value)
		
		// See protocol.
		@EffectBuilder<Lowered>
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects):
				Lowered.do(try effects.lowered(in: &context))
				
				case .let(let definitions, in: let effect):
				try Lowered.let(definitions.lowered(in: &context), in: effect.lowered(in: &context))
				
				case .setElement(of: let vector, at: let index, to: let element):
				let vec = context.bag.uniqueName(from: "vec")
				let idx = context.bag.uniqueName(from: "idx")
				let elem = context.bag.uniqueName(from: "elem")
				try Lowered.let([
					.init(vec, vector.lowered(in: &context)),
					.init(idx, index.lowered(in: &context)),
					.init(elem, element.lowered(in: &context)),
				], in: .setElement(of: vec, at: .symbol(idx), to: .symbol(elem)))
				
			}
		}
		
	}
	
}
