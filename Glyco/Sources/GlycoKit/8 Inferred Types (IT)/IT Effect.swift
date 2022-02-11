// Glyco © 2021–2022 Constantino Tsarouhas

extension IT {
	
	/// An effect on an IT machine.
	public enum Effect : ComposableEffect, Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(Location, to: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
		/// An effect that pushes a vector of `count` elements to the call frame and puts a capability for that vector in `into`.
		case allocateVector(ValueType, count: Int = 1, into: Location)
		
		/// An effect that retrieves the element at zero-based position `at` in the vector in `of` and puts it in `to`.
		///
		/// When a data type is provided, it must be compatible with the vector's element type. When no data type is provided, it is inferred from the vector's type.
		case getElement(ValueType? = nil, of: Location, at: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		///
		/// When a data type is provided, it must be compatible with the vector's element type. When no data type is provided, it is inferred from the vector's type.
		case setElement(ValueType? = nil, of: Location, at: Source, to: Source)
		
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
				let type = try context.typeAssignments[source]
				Lowered.set(type, destination, to: source)
				try context.typeAssignments.assign(type, to: destination)
				
				case .compute(let lhs, let operation, let rhs, to: let destination):
				Lowered.compute(lhs, operation, rhs, to: destination)
				try context.typeAssignments.assign(.signedWord, to: destination)
				
				case .allocateVector(let type, count: let count, into: let vector):
				Lowered.allocateVector(type, count: count, into: vector)	// TODO: Compound types
				
				case .getElement(let type, of: let vector, at: let index, to: let destination):
				Lowered.getElement(type ?? .signedWord, of: vector, at: index, to: destination)	// TODO
				
				case .setElement(let type, of: let vector, at: let index, to: let element):
				Lowered.setElement(type ?? .signedWord, of: vector, at: index, to: element)	// TODO
				
				case .if(let predicate, then: let affirmative, else: let negative):
				try Lowered.if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .push(let source):
				Lowered.push(try context.typeAssignments[source], source)
				
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
