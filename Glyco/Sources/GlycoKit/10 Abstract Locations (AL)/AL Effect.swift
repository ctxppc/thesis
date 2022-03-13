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
		
		/// An effect that calls the procedure with given name and uses given parameter registers.
		///
		/// This effect assumes a suitable calling convention has already been applied to the program. The parameter registers are only used for the purposes of liveness analysis.
		case call(Label, parameters: [Register])
		
		/// An effect that jumps to the address in `target` after unsealing it, and puts the datum in `data` in `invocationData` after unsealing it.
		case invoke(target: Source, data: Source)
		
		/// An effect that returns to the caller.
		case `return`
		
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
				
				case .call(let name, parameters: let parameters):
				return .call(name, parameters: parameters, analysisAtEntry: .init())
				
				case .invoke(target: let target, data: let data):
				return .invoke(target: target, data: data, analysisAtEntry: .init())
				
				case .return:
				return .return(analysisAtEntry: .init())
				
			}
		}
		
		// See protocol.
		var subeffects: [Self]? {
			guard case .do(let subeffects) = self else { return nil }
			return subeffects
		}
		
	}
	
}
