// Glyco © 2021–2022 Constantino Tsarouhas

extension ID {
	
	/// An effect on an ID machine.
	public enum Effect : SimplyLowerable, ComposableEffect {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(Location, to: Source)
		
		/// An effect that computes given expression and puts the result in given location.
		case compute(Location, Source, BinaryOperator, Source)
		
		/// An effect that creates an (uninitialised) buffer of `bytes` bytes and puts a capability for that buffer in given location.
		///
		/// If `scoped` is `true`, the buffer may be destroyed when the current scope is popped and must not be accessed afterwards.
		case createBuffer(bytes: Int, capability: Location, scoped: Bool)
		
		/// An effect that destroys the buffer referred by the capability from given source.
		///
		/// This effect must only be used with *scoped* buffers created in the *current* scope. For any two buffers *a* and *b* created in the current scope, *b* must be destroyed exactly once before destroying *a*. Destruction is not required before popping the scope; in that case, destruction is automatic.
		case destroyBuffer(capability: Source)
		
		/// An effect that retrieves the datum at offset `offset` in the buffer in `of` and puts it in `to`.
		case getElement(DataType, of: Location, offset: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the buffer in `of` at offset `offset`.
		case setElement(DataType, of: Location, offset: Source, to: Source)
		
		/// An effect that creates a capability that can be used for sealing with a unique object type and puts it in given location.
		case createSeal(in: Location)
		
		/// An effect that seals the capability in `source` using the sealing capability in `seal` and puts it in `into`.
		case seal(into: Location, source: Location, seal: Location)
		
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
		
		/// An effect that clears all registers except the structural registers `csp`, `cgp`, `ctp`, and `cfp` as well as given registers.
		case clearAll(except: [Register])
		
		/// An effect that calls the procedure with given target code capability and uses given parameter registers.
		///
		/// This effect assumes a suitable calling convention has already been applied to the program. The parameter registers are only used for the purposes of liveness analysis.
		case call(Source, parameters: [Register])
		
		/// An effect that calls the procedure with given target code capability and data capability (both sealed with the same object type) and uses given unsealed parameter registers.
		///
		/// This effect assumes a suitable calling convention has already been applied to the program. The unsealed parameter registers are only used for the purposes of liveness analysis.
		case callSealed(Source, data: Source, unsealedParameters: [Register])
		
		/// An effect that returns control to the caller with given target code capability (which is usually `cra`).
		case `return`(to: Source)
		
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
				
				case .createBuffer(bytes: let bytes, capability: let buffer, scoped: let scoped):
				try context.declarations.declare(buffer, type: .cap)
				Lowered.createBuffer(bytes: bytes, capability: buffer, scoped: scoped)
				
				case .destroyBuffer(capability: let buffer):
				try context.declarations.require(buffer, type: .cap)
				Lowered.destroyBuffer(capability: buffer)
				
				case .getElement(let elementType, of: let buffer, offset: let offset, to: let destination):
				try context.declarations.declare(destination, type: elementType)
				Lowered.getElement(elementType, of: buffer, offset: offset, to: destination)
				
				case .setElement(let elementType, of: let buffer, offset: let offset, to: let element):
				try context.declarations.require(element, type: elementType)
				Lowered.setElement(elementType, of: buffer, offset: offset, to: element)
				
				case .createSeal(in: let seal):
				try context.declarations.declare(seal, type: .cap)
				Lowered.createSeal(in: seal)
				
				case .seal(into: let destination, source: let source, seal: let seal):
				try context.declarations.require(source, type: .cap)
				try context.declarations.require(seal, type: .cap)
				try context.declarations.declare(destination, type: .cap)
				Lowered.seal(into: destination, source: source, seal: seal)
				
				case .if(let predicate, then: let affirmative, else: let negative):
				try Lowered.if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .pushScope:
				Lowered.pushScope
				
				case .popScope:
				Lowered.popScope
				
				case .clearAll(except: let sparedRegisters):
				Lowered.clearAll(except: sparedRegisters)
				
				case .call(let target, parameters: let parameters):
				Lowered.call(target, parameters: parameters)
				
				case .callSealed(let target, data: let data, unsealedParameters: let unsealedParameters):
				Lowered.callSealed(target, data: data, unsealedParameters: unsealedParameters)
				
				case .return(to: let caller):
				try context.declarations.require(caller, type: .cap)
				Lowered.return(to: caller)
				
			}
		}
		
		// See protocol.
		var subeffects: [Self]? {
			guard case .do(let subeffects) = self else { return nil }
			return subeffects
		}
		
	}
	
}
