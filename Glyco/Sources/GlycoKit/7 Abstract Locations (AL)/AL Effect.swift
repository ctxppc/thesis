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
		
		/// An effect that pushes a buffer of `bytes` bytes to the call frame and puts a capability for that buffer in given location.
		case allocateBuffer(bytes: Int, into: Location)
		
		/// An effect that pushes a vector of `count` elements to the call frame and puts a capability for that vector in given location.
		case allocateVector(count: Int = 1, into: Location)
		
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
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects):
				return .do(try effects.lowered(in: &context), analysisAtEntry: .init())
				
				case .set(let destination, to: let source):
				return .set(destination, to: source, analysisAtEntry: .init())
				
				case .compute(let lhs, let operation, let rhs, to: let destination):
				return .compute(lhs, operation, rhs, to: destination, analysisAtEntry: .init())
				
				case .allocateBuffer(bytes: let bytes, into: let buffer):
				return .allocateBuffer(bytes: bytes, into: buffer, analysisAtEntry: .init())
				
				case .allocateVector(count: let count, into: let vector):
				return .allocateVector(count: count, into: vector, analysisAtEntry: .init())
				
				case .getElement(of: let vector, at: let index, to: let destination):
				return .getElement(of: vector, at: index, to: destination, analysisAtEntry: .init())
				
				case .setElement(of: let vector, at: let index, to: let element):
				return .setElement(of: vector, at: index, to: element, analysisAtEntry: .init())
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(
					predicate.lowered(in: &context),
					then:				affirmative.lowered(in: &context),
					else:				negative.lowered(in: &context),
					analysisAtEntry:	.init()
				)
				
				case .push(let source):
				return .push(source, analysisAtEntry: .init())
				
				case .pop(bytes: let bytes):
				return .pop(bytes: bytes, analysisAtEntry: .init())
				
				case .pushScope:
				return .pushScope(analysisAtEntry: .init())
				
				case .popScope:
				return .popScope(analysisAtEntry: .init())
				
				case .call(let name, let parameters):
				return .call(name, parameters, analysisAtEntry: .init())
				
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
