// Glyco © 2021–2022 Constantino Tsarouhas

extension LS {
	
	/// An effect on an LS machine.
	public enum Effect : SimplyLowerable, ComposableEffect {
		
		/// An effect that performs given effects.
		case `do`([Effect])
		
		/// An effect that performs given effect after associating zero or more values with a name.
		indirect case `let`([Definition], in: Effect)
		
		/// An effect that evaluates `to` and puts it in the field with given name in the record in `of`.
		case setField(Field.Name, of: Symbol, to: Source)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(of: Symbol, at: Source, to: Source)
		
		// See protocol.
		@EffectBuilder<Lowered>
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects):
				Lowered.do(try effects.lowered(in: &context))
				
				case .let(let definitions, in: let effect):
				context.pushScope(for: definitions.lazy.map(\.name))
				try Lowered.let(definitions.lowered(in: &context), in: effect.lowered(in: &context))
				context.popScope(for: definitions.lazy.map(\.name))
				
				case .setField(let fieldName, of: let record, to: let element):
				try Lowered.setField(fieldName, of: record.lowered(in: &context), to: element.lowered(in: &context))
				
				case .setElement(of: let vector, at: let index, to: let element):
				try Lowered.setElement(of: vector.lowered(in: &context), at: index.lowered(in: &context), to: element.lowered(in: &context))
				
			}
		}
		
		// See protocol.
		var subeffects: [Self]? {
			guard case .do(let subeffects) = self else { return nil }
			return subeffects
		}
		
	}
	
}
