// Glyco © 2021–2022 Constantino Tsarouhas

extension RC {
	
	/// An effect on an RC machine.
	public enum Effect : ComposableEffect, Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(Location, to: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
		/// An effect that pushes a record of given type to the call frame and puts a capability for that record in given location.
		case allocateRecord(RecordType, into: Location)
		
		/// An effect that retrieves the field with given name in the record in `of` and puts it in `to`.
		case getField(RecordType.Field.Name, of: Location, to: Location)
		
		/// An effect that evaluates `to` and puts it in the field with given name in the record in `of`.
		case setField(RecordType.Field.Name, of: Location, to: Location)
		
		/// An effect that pushes a vector of `count` elements of given value type to the call frame and puts a capability for that vector in given location.
		case allocateVector(ValueType, count: Int = 1, into: Location)
		
		/// An effect that retrieves the element at zero-based position `at` in the vector in `of` and puts it in `to`.
		case getElement(of: Location, at: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(of: Location, at: Source, to: Source)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect)
		
		/// An effect that retrieves the value from given source and pushes it to the call frame.
		case push(Source)
		
		/// An effect that removes `bytes` bytes from the stack.
		case pop(bytes: Int)
		
		/// Pushes a new scope to the scope stack.
		///
		/// This effect protects callee-saved physical locations (registers and frame locations) from the previous scope that may be defined in the new scope.
		///
		/// This effect must be executed exactly once before any location defined in the current scope is accessed.
		case pushScope
		
		/// Pops a scope from the scope stack.
		///
		/// This effect restores physical locations (registers and frame locations) previously saved using `pushScope(_:)`.
		///
		/// This effect must be executed exactly once before any location defined in the previous scope is accessed.
		case popScope
		
		/// An effect that invokes the labelled procedure and uses given locations.
		///
		/// This effect assumes a suitable calling convention has already been applied to the program. The locations are only used for the purposes of liveness analysis.
		case call(Label, [Location])
		
		/// An effect that returns to the caller.
		case `return`
		
		// See protocol.
		@EffectBuilder<Lower.Effect>
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects):
				Lowered.do(try effects.lowered(in: &context))
				
				case .set(let destination, to: let source):
				Lowered.set(destination, to: source)
				
				case .compute(let lhs, let operation, let rhs, to: let destination):
				Lowered.compute(lhs, operation, rhs, to: destination)
				
				case .allocateRecord(let recordType, into: let record):
				Lowered.allocateBuffer(bytes: recordType.byteSize, into: record)
				
				case .getField(let name, of: let record, to: let destination):
				Lowered.do([])	// TODO
				
				case .setField(let name, of: let record, to: let source):
				Lowered.do([])	// TODO
				
				case .allocateVector(let elementType, count: let count, into: let vector):
				Lowered.allocateBuffer(bytes: 0, into: vector)	// TODO
				
				case .getElement(of: let vector, at: let index, to: let destination):
				Lowered.getElement(.signedWord, of: vector, at: index, to: destination)	// TODO: Element type
				
				case .setElement(of: let vector, at: let index, to: let element):
				Lowered.setElement(.signedWord, of: vector, at: index, to: element)		// TODO: Element type
				
				case .if(let predicate, then: let affirmative, else: let negative):
				try Lowered.if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .push(let source):
				Lowered.push(source)
				
				case .pop(bytes: let bytes):
				Lowered.pop(bytes: bytes)
				
				case .pushScope:
				Lowered.pushScope
				
				case .popScope:
				Lowered.popScope
				
				case .call(let name, let parameters):
				Lowered.call(name, parameters)
				
				case .return:
				Lowered.return
				
			}
		}
		
		// See protocol.
		var subeffects: [Self]? {
			guard case .do(let subeffects) = self else { return nil }
			return subeffects
		}
		
	}
	
}
