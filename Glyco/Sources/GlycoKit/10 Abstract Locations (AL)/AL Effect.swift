// Glyco © 2021–2022 Constantino Tsarouhas

extension AL {
	
	/// An effect on an AL machine.
	public enum Effect : ComposableEffect, Codable, Equatable, SimplyLowerable {
		
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
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects):
				return .do(try effects.lowered(in: &context), analysisAtEntry: .init())
				
				case .set(let destination, to: let source):
				return .set(destination, to: source, analysisAtEntry: .init())
				
				case .compute(let destination, let lhs, let operation, let rhs):
				return .compute(destination, lhs, operation, rhs, analysisAtEntry: .init())
				
				case .createBuffer(bytes: let bytes, capability: let buffer, scoped: let scoped):
				return .createBuffer(bytes: bytes, capability: buffer, scoped: scoped, analysisAtEntry: .init())
				
				case .destroyBuffer(capability: let buffer):
				return .destroyBuffer(capability: buffer, analysisAtEntry: .init())
				
				case .getElement(let elementType, of: let vector, offset: let offset, to: let destination):
				return .getElement(elementType, of: vector, offset: offset, to: destination, analysisAtEntry: .init())
				
				case .setElement(let elementType, of: let vector, offset: let offset, to: let element):
				return .setElement(elementType, of: vector, offset: offset, to: element, analysisAtEntry: .init())
				
				case .createSeal(in: let destination):
				return .createSeal(in: destination, analysisAtEntry: .init())
				
				case .seal(into: let destination, source: let source, seal: let seal):
				return .seal(into: destination, source: source, seal: seal, analysisAtEntry: .init())
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(
					predicate.lowered(in: &context),
					then:				affirmative.lowered(in: &context),
					else:				negative.lowered(in: &context),
					analysisAtEntry:	.init()
				)
				
				case .pushScope:
				return .pushScope(analysisAtEntry: .init())
				
				case .popScope:
				return .popScope(analysisAtEntry: .init())
				
				case .clearAll(except: let sparedRegisters):
				return .clearAll(except: sparedRegisters, analysisAtEntry: .init())
				
				case .call(let target, parameters: let parameters):
				return .call(target, parameters: parameters, analysisAtEntry: .init())
				
				case .callSealed(let target, data: let data, unsealedParameters: let unsealedParameters):
				return .callSealed(target, data: data, unsealedParameters: unsealedParameters, analysisAtEntry: .init())
				
				case .return(to: let caller):
				return .return(to: caller, analysisAtEntry: .init())
				
			}
		}
		
		// See protocol.
		var subeffects: [Self]? {
			guard case .do(let subeffects) = self else { return nil }
			return subeffects
		}
		
	}
	
}
