// Glyco © 2021–2022 Constantino Tsarouhas

extension CA {
	
	/// An effect on a CA machine.
	public enum Effect : ComposableEffect, Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(Location, to: Value)
		
		/// An effect that evaluates `to` and puts it in the field with given name in the record in `of`.
		case setField(RecordType.Field.Name, of: Location, to: Source)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(of: Location, at: Source, to: Source)
		
		/// An effect that invokes the labelled procedure passing given arguments and puts the procedure's result in `result`.
		case call(Label, [Source], result: Location)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect)
		
		/// An effect that terminates the program with `result`.
		case `return`(Source)
		
		// See protocol.
		@EffectBuilder<Lowered>
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects):
				Lowered.do(try effects.lowered(in: &context))
				
				case .set(let destination, to: .source(let source)):
				Lowered.set(destination, to: source)
				
				case .set(let destination, to: .binary(let lhs, let op, let rhs)):
				Lowered.compute(destination, lhs, op, rhs)
				
				case .set(let destination, to: .record(let type)):
				Lowered.createRecord(type, capability: destination, scoped: true)	// FIXME: Unscoped record when escaping
				
				case .set(let destination, to: .field(let fieldName, of: let record)):
				Lowered.getField(fieldName, of: record, to: destination)
				
				case .set(let destination, to: .vector(let elementType, count: let count)):
				Lowered.createVector(elementType, count: count, capability: destination, scoped: true)	// FIXME: Unscoped record when escaping
				
				case .set(let destination, to: .element(of: let vector, at: let index)):
				Lowered.getElement(of: vector, index: index, to: destination)
				
				case .set(let destination, to: .seal):
				Lowered.createSeal(in: destination)
				
				case .set(let destination, to: .sealed(let source, with: let seal)):
				Lowered.seal(into: destination, source: source, seal: seal)
				
				case .setField(let fieldName, of: let record, to: let element):
				Lowered.setField(fieldName, of: record, to: element)
				
				case .setElement(of: let vector, at: let index, to: let element):
				Lowered.setElement(of: vector, index: index, to: element)
				
				case .call(let name, let arguments, result: let result):
				Lowered.call(name, arguments, result: result)
				
				case .if(let predicate, then: let affirmative, else: let negative):
				try Lowered.if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .return(let result):
				Lowered.return(result)
				
			}
		}
		
		// See protocol.
		var subeffects: [Self]? {
			guard case .do(let subeffects) = self else { return nil }
			return subeffects
		}
		
	}
	
}
