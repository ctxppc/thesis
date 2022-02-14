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
		
		/// An effect that pushes a buffer of `bytes` bytes to the call frame and puts a capability for that buffer in given location.
		case allocateBuffer(bytes: Int, into: Location)
		
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
				try context.declarations.declare(destination, type: context.declarations.type(of: source))
				Lowered.set(destination, to: source)
				
				case .compute(let lhs, let operation, let rhs, to: let destination):
				try context.declarations.require(lhs, type: .signedWord)
				try context.declarations.require(rhs, type: .signedWord)
				try context.declarations.declare(destination, type: .signedWord)
				Lowered.compute(lhs, operation, rhs, to: destination)
				
				case .allocateBuffer(bytes: let bytes, into: let buffer):
				try context.declarations.declare(buffer, type: .capability(nil))
				Lowered.allocateBuffer(bytes: bytes, into: buffer)
				
				case .allocateVector(let elementType, count: let count, into: let vector):
				try context.declarations.declare(vector, type: .capability(elementType))
				Lowered.allocateVector(count: count, into: vector)
				
				case .getElement(of: let vector, at: let index, to: let destination):
				let elementType = try context.declarations.elementType(vector: vector)
				try context.declarations.declare(destination, type: elementType)
				Lowered.getElement(elementType.lowered(), of: vector, at: index, to: destination)
				
				case .setElement(of: let vector, at: let index, to: let element):
				let elementType = try context.declarations.elementType(vector: vector)
				try context.declarations.require(element, type: elementType)
				Lowered.setElement(elementType.lowered(), of: vector, at: index, to: element)
				
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
