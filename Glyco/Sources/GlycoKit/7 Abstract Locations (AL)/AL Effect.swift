// Glyco © 2021–2022 Constantino Tsarouhas

extension AL {
	
	/// An effect on an AL machine.
	public enum Effect : ComposableEffect, Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(Location, to: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
		/// An effect that pushes a buffer of `bytes` bytes to the call scope and puts a capability for that buffer in given location.
		case pushBuffer(bytes: Int, into: Location)
		
		/// An effect that pops the buffer referred by the capability from given source.
		///
		/// This effect must only be used with buffers allocated in the current call scope. For any two buffers *a* and *b* allocated in the current call scope, *b* must be deallocated exactly once before deallocating *a*. Deallocation is not required before popping the call scope; in that case, deallocation is automatic.
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
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects):
				return .do(try effects.lowered(in: &context), analysisAtEntry: .init())
				
				case .set(let destination, to: let source):
				return .set(destination, to: source, analysisAtEntry: .init())
				
				case .compute(let lhs, let operation, let rhs, to: let destination):
				return .compute(lhs, operation, rhs, to: destination, analysisAtEntry: .init())
				
				case .pushBuffer(bytes: let bytes, into: let buffer):
				return .pushBuffer(bytes: bytes, into: buffer, analysisAtEntry: .init())
				
				case .popBuffer(let buffer):
				return .popBuffer(buffer, analysisAtEntry: .init())
				
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
				
				case .call(let name, parameters: let parameters):
				return .call(name, parameters: parameters, analysisAtEntry: .init())
				
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
