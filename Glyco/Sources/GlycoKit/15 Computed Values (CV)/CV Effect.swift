// Glyco © 2021–2022 Constantino Tsarouhas

extension CV {
	
	/// An effect on a CV machine.
	public enum Effect : ComposableEffect, Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs given effects.
		case `do`([Effect])
		
		/// An effect that evaluates given value and puts it in given location.
		case set(Location, to: Value)
		
		/// An effect that evaluates `to` and puts it in the field with given name in the record in `of`.
		case setField(Field.Name, of: Location, to: Source)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(of: Location, at: Source, to: Source)
		
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
				Lowered.set(destination, to: .source(source))
					
				case .set(let destination, to: .binary(let lhs, let op, let rhs)):
				Lowered.set(destination, to: .binary(lhs, op, rhs))
				
				case .set(let destination, to: .record(let type)):
				Lowered.set(destination, to: .record(type))
				
				case .set(let destination, to: .field(let fieldName, of: let record)):
				Lowered.set(destination, to: .field(fieldName, of: record))
				
				case .set(let destination, to: .vector(let elementType, count: let count)):
				Lowered.set(destination, to: .vector(elementType, count: count))
				
				case .set(let destination, to: .element(of: let vector, at: let index)):
				Lowered.set(destination, to: .element(of: vector, at: index))
				
				case .set(let destination, to: .seal):
				Lowered.set(destination, to: .seal)
				
				case .set(let destination, to: .sealed(let source, with: let seal)):
				Lowered.set(destination, to: .sealed(source, with: seal))
				
				case .set(let destination, to: .evaluate(let procedure, let arguments)):
				Lowered.call(procedure, arguments, result: destination)
				
				case .set(let destination, to: .if(let predicate, then: let affirmative, else: let negative)):
				try Lowered.if(
					predicate.lowered(in: &context),
					then: Self.set(destination, to: affirmative).lowered(in: &context),
					else: Self.set(destination, to: negative).lowered(in: &context)
				)
				
				case .set(let destination, to: .do(let effects, then: let source)):
				try Lowered.do(effects.lowered(in: &context))
				try Self.set(destination, to: source).lowered(in: &context)
				
				case .setField(let fieldName, of: let record, to: let element):
				Lowered.setField(fieldName, of: record, to: element)
				
				case .setElement(of: let vector, at: let index, to: let element):
				Lowered.setElement(of: vector, at: index, to: element)
				
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
