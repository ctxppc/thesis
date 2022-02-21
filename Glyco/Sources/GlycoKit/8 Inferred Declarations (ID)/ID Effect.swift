// Glyco © 2021–2022 Constantino Tsarouhas

extension ID {
	
	/// An effect on an ID machine.
	public enum Effect : ComposableEffect, Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(Location, to: Source)
		
		/// An effect that computes given expression and puts the result in given location.
		case compute(Location, Source, BinaryOperator, Source)
		
		/// An effect that pushes a buffer of `bytes` bytes to the current scope and puts a capability for that buffer in given location.
		case pushBuffer(bytes: Int, into: Location)
		
		/// An effect that pops the buffer referred by the capability from given source.
		///
		/// This effect must only be used with buffers allocated in the current scope. For any two buffers *a* and *b* allocated in the current scope, *b* must be deallocated exactly once before deallocating *a*. Deallocation is not required before popping the scope; in that case, deallocation is automatic.
		case popBuffer(Source)
		
		/// An effect that retrieves the datum at offset `offset` in the buffer in `of` and puts it in `to`.
		case getElement(DataType, of: Location, offset: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the buffer in `of` at offset `offset`.
		case setElement(DataType, of: Location, offset: Source, to: Source)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect)
		
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
		
		/// An effect that invokes the labelled procedure and uses given parameter registers.
		///
		/// This effect assumes a suitable calling convention has already been applied to the program. The parameter registers are only used for the purposes of liveness analysis.
		case call(Label, parameters: [Register])
		
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
				
				case .compute(let destination, let lhs, let operation, let rhs):
				try context.declarations.require(lhs, type: .s32)
				try context.declarations.require(rhs, type: .s32)
				try context.declarations.declare(destination, type: .s32)
				Lowered.compute(destination, lhs, operation, rhs)
				
				case .pushBuffer(bytes: let bytes, into: let buffer):
				try context.declarations.declare(buffer, type: .cap)
				Lowered.pushBuffer(bytes: bytes, into: buffer)
				
				case .popBuffer(capability: let buffer):
				try context.declarations.require(buffer, type: .cap)
				Lowered.popBuffer(buffer)
				
				case .getElement(let elementType, of: let buffer, offset: let offset, to: let destination):
				try context.declarations.declare(destination, type: elementType)
				Lowered.getElement(elementType, of: buffer, offset: offset, to: destination)
				
				case .setElement(let elementType, of: let buffer, offset: let offset, to: let element):
				try context.declarations.require(element, type: elementType)
				Lowered.setElement(elementType, of: buffer, offset: offset, to: element)
				
				case .if(let predicate, then: let affirmative, else: let negative):
				try Lowered.if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .pushScope:
				Lowered.pushScope
				
				case .popScope:
				Lowered.popScope
				
				case .call(let name, parameters: let parameters):
				Lowered.call(name, parameters: parameters)
				
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
