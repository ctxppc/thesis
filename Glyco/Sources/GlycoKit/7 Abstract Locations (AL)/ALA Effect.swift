// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// An effect on an ALA machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect], analysisAtEntry: Analysis)
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(ValueType, Location, to: Source, analysisAtEntry: Analysis)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location, analysisAtEntry: Analysis)
		
		/// An effect that pushes a vector of `count` elements to the call frame and puts a capability for that vector in `into`.
		case allocateVector(ValueType, count: Int = 1, into: Location, analysisAtEntry: Analysis)
		
		/// An effect that retrieves the element at zero-based position `at` in the vector in `of` and puts it in `to`.
		case getElement(ValueType, of: Location, at: Source, to: Location, analysisAtEntry: Analysis)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(ValueType, of: Location, at: Source, to: Source, analysisAtEntry: Analysis)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect, analysisAtEntry: Analysis)
		
		/// An effect that retrieves the value from given source and pushes it to the call frame.
		case push(ValueType, Source, analysisAtEntry: Analysis)
		
		/// An effect that removes `bytes` bytes from the stack.
		case pop(bytes: Int, analysisAtEntry: Analysis)
		
		/// Pushes a new scope to the scope stack, protecting any callee-saved physical locations (registers and frame locations) from the previous scope that may be defined in the new scope.
		///
		/// This effect must be executed exactly once before any location defined in the current scope is accessed.
		///
		/// A push scope effect "defines" all callee-saved registers with the value from the previous scope. If nothing else is done, callee-saved registers will conflict with every location that is live at any point until the pop scope effect and will not be used for assignment.
		///
		/// To make callee-saved registers available for assignment, they should be copied into abstract locations after pushing the scope, and copied back into the register prior to popping the scope. The latter copy will cause the registers to be marked as definitely discarded between the two copies, thereby making them available for assignment. Any register not used for assignment will be coalesced with its abstract location, thereby eliding the copy effects to and from the abstract location.
		case pushScope(analysisAtEntry: Analysis)
		
		/// Pops a scope from the scope stack, restoring any physical locations (registers and frame locations) previously saved using `pushScope`.
		///
		/// This effect must be executed exactly once before any location defined in the previous scope is accessed.
		///
		/// A pop scope effect "uses" the values of callee-saved registers, as defined during the preceding push scope effect so that it can "return" them to the previous scope. If those values were copied into abstract locations after their definition by the push scope effect, they should be copied back to the callee-saved registers before the pop scope effect so that the registers become available for other assignments.
		case popScope(analysisAtEntry: Analysis)
		
		/// An effect that invokes the labelled procedure and uses given physical locations.
		///
		/// This effect assumes a suitable calling convention has already been applied to the program. The locations are only used for the purposes of liveness analysis.
		case call(Label, [Location], analysisAtEntry: Analysis)
		
		/// An effect that returns to the caller.
		///
		/// This effect assumes a suitable calling convention has already been applied to the program.
		case `return`(analysisAtEntry: Analysis)
		
		// See protocol.
		@EffectBuilder<Lowered>
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects, analysisAtEntry: _):
				Lowered.do(try effects.lowered(in: &context))
				
				case .set(let type, let destination, to: let source, analysisAtEntry: _):
				try Lowered.set(type.lowered(), destination.lowered(in: &context), to: source.lowered(in: &context))
				
				case .compute(let lhs, let op, let rhs, to: let destination, analysisAtEntry: _):
				try Lowered.compute(lhs.lowered(in: &context), op, rhs.lowered(in: &context), to: destination.lowered(in: &context))
				
				case .allocateVector(let type, count: let count, into: let vector, analysisAtEntry: _):
				Lowered.allocateVector(type.lowered(), count: count, into: try vector.lowered(in: &context))
				
				case .getElement(let type, of: let vector, at: let index, to: let destination, analysisAtEntry: _):
				try Lowered.getElement(type.lowered(), of: vector.lowered(in: &context), at: index.lowered(in: &context), to: destination.lowered(in: &context))
				
				case .setElement(let type, of: let vector, at: let index, to: let source, analysisAtEntry: _):
				try Lowered.setElement(type.lowered(), of: vector.lowered(in: &context), at: index.lowered(in: &context), to: source.lowered(in: &context))
				
				case .if(let predicate, then: let affirmative, else: let negative, analysisAtEntry: _):
				try Lowered.if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .push(let type, let source, analysisAtEntry: _):
				Lowered.push(type.lowered(), try source.lowered(in: &context))
				
				case .pop(bytes: let bytes, analysisAtEntry: _):
				Lowered.pop(bytes: bytes)
				
				case .pushScope(analysisAtEntry: _):
				Lowered.pushFrame(bytes: context.assignments.frame.allocatedByteSize)
				
				case .popScope(analysisAtEntry: _):
				Lowered.popFrame
				
				case .call(let name, _, analysisAtEntry: _):
				Lowered.call(name)
				
				case .return(analysisAtEntry: _):
				Lowered.return
				
			}
		}
		
		/// Returns a (possibly) transformed copy of `self` with updated analysis at entry.
		///
		/// The transformation is applied first. If the transformed effect contains children, it is applied to those children as well.
		///
		/// - Parameters:
		///    - transform: A function that transforms effects.
		///    - analysis: On method entry, analysis at exit of `self`. On method exit, the analysis at entry of `self`.
		///
		/// - Returns: `transform(self)` with updated analysis at entry.
		func updated(using transform: Transformation, analysis: inout Analysis) throws -> Self {
			let transformed = try transform(self)
			try analysis.update(defined: transformed.definedLocations(), possiblyUsed: transformed.possiblyUsedLocations())
			switch transformed {
				
				case .do(let effects, analysisAtEntry: _):
				return .do(
					try effects
						.reversed()
						.map { try $0.updated(using: transform, analysis: &analysis) }	// update effects in reverse order so that analysis flows backwards
						.reversed(),													// reverse back to normal order
					analysisAtEntry: analysis
				)
				
				case .set(let type, let destination, to: let source, analysisAtEntry: _):
				return .set(type, destination, to: source, analysisAtEntry: analysis)
				
				case .compute(let lhs, let operation, let rhs, to: let destination, analysisAtEntry: _):
				return .compute(lhs, operation, rhs, to: destination, analysisAtEntry: analysis)
				
				case .allocateVector(let type, count: let count, into: let vector, analysisAtEntry: _):
				return .allocateVector(type, count: count, into: vector, analysisAtEntry: analysis)
				
				case .getElement(let type, of: let vector, at: let index, to: let destination, analysisAtEntry: _):
				return .getElement(type, of: vector, at: index, to: destination, analysisAtEntry: analysis)
				
				case .setElement(let type, of: let vector, at: let index, to: let element, analysisAtEntry: _):
				return .setElement(type, of: vector, at: index, to: element, analysisAtEntry: analysis)
				
				case .if(let predicate, then: let affirmative, else: let negative, analysisAtEntry: _):
				do {
					
					/*			      analysisAtEntry
					┌────────────────────────┼────────────────────────┐
					│    ┌───────────────────▼───────────────────┐    │
					│    │                                       │    │
					│    │               Predicate               │    │
					│    │                                       │    │
					│    └───────┬───────────────────────┬───────┘    │
					│ analysisAtAffirmativeEntry         │            │
					│    ┌───────▼────────┐     ┌────────▼───────┐    │
					│    │  Affirmative   │     │    Negative    │    │
					│    │     branch     │     │     branch     │    │
					│    └───────┬────────┘     └────────┬───────┘    │
					│            │                       │            │
					└────────────┼───────────────────────┼────────────┘
								 │                       │
								 └───────────┬───────────┘
											 │
											 ▼
					 */
					
					var analysisAtAffirmativeEntry = analysis
					let updatedAffirmative = try affirmative.updated(using: transform, analysis: &analysisAtAffirmativeEntry)
					
					let updatedNegative = try negative.updated(using: transform, analysis: &analysis)
					analysis.formUnion(with: analysisAtAffirmativeEntry)
					
					let updatedPredicate = try predicate.updated(using: transform, analysis: &analysis)
					
					return .if(updatedPredicate, then: updatedAffirmative, else: updatedNegative, analysisAtEntry: analysis)
					
				}
				
				case .push(let dataType, let source, analysisAtEntry: _):
				return .push(dataType, source, analysisAtEntry: analysis)
				
				case .pop(bytes: let bytes, analysisAtEntry: _):
				return .pop(bytes: bytes, analysisAtEntry: analysis)
				
				case .pushScope(analysisAtEntry: _):
				return .pushScope(analysisAtEntry: analysis)
				
				case .popScope(analysisAtEntry: _):
				return .popScope(analysisAtEntry: analysis)
				
				case .call(let name, let locations, analysisAtEntry: _):
				return .call(name, locations, analysisAtEntry: analysis)
				
				case .return(analysisAtEntry: _):
				return .return(analysisAtEntry: analysis)
				
			}
		}
		
		/// A function that transforms an effect into the same effect or different effect.
		typealias Transformation = (Self) throws -> Self
		
		/// The analysis of `self` at entry.
		var analysisAtEntry: Analysis {
			switch self {
				case .do(_, analysisAtEntry: let analysis),
					.set(_, _, to: _, analysisAtEntry: let analysis),
					.compute(_, _, _, to: _, analysisAtEntry: let analysis),
					.allocateVector(_, count: _, into: _, analysisAtEntry: let analysis),
					.getElement(_, of: _, at: _, to: _, analysisAtEntry: let analysis),
					.setElement(_, of: _, at: _, to: _, analysisAtEntry: let analysis),
					.if(_, then: _, else: _, analysisAtEntry: let analysis),
					.push(_, _, analysisAtEntry: let analysis),
					.pop(bytes: _, analysisAtEntry: let analysis),
					.pushScope(analysisAtEntry: let analysis),
					.popScope(analysisAtEntry: let analysis),
					.call(_, _, analysisAtEntry: let analysis),
					.return(analysisAtEntry: let analysis):
				return analysis
			}
		}
		
		/// Returns the locations defined by `self`.
		private func definedLocations() -> [Location] {
			switch self {
				
				case .do, .setElement, .if, .push, .pop, .popScope, .call, .return:
				return []
				
				case .set(_, let destination, to: _, analysisAtEntry: _),
					.getElement(_, of: _, at: _, to: let destination, analysisAtEntry: _),
					.compute(_, _, _, to: let destination, analysisAtEntry: _),
					.allocateVector(_, count: _, into: let destination, analysisAtEntry: _):
				return [destination]
				
				case .pushScope:
				return Lower.Register.defaultCalleeSavedRegisters.map { .register($0) }
				
			}
		}
		
		/// Returns the locations possibly used by `self`.
		private func possiblyUsedLocations() -> [Location] {
			switch self {
				
				case .do,
					.set(_, _, to: .constant, analysisAtEntry: _),
					.compute(.constant, _, .constant, to: _, analysisAtEntry: _),
					.allocateVector,
					.if,
					.push(_, .constant, analysisAtEntry: _),
					.pop,
					.pushScope,
					.return:
				return []
				
				case .set(_, _, to: let source, analysisAtEntry: _),
					.push(_, let source, analysisAtEntry: _):
				return [source].compactMap(\.location)
				
				case .compute(let lhs, _, let rhs, to: _, analysisAtEntry: _):
				return [lhs, rhs].compactMap(\.location)
				
				case .getElement(_, of: let vector, at: .constant, to: _, analysisAtEntry: _),
					.setElement(_, of: let vector, at: .constant, to: _, analysisAtEntry: _):
				return [vector]
				
				case .getElement(_, of: let vector, at: let index, to: _, analysisAtEntry: _),
					.setElement(_, of: let vector, at: let index, to: _, analysisAtEntry: _):
				return [index].compactMap(\.location) + [vector]
				
				case .popScope:
				return Lower.Register.defaultCalleeSavedRegisters.map { .register($0) }
				
				case .call(_, let arguments, analysisAtEntry: _):
				return arguments
				
			}
		}
		
		/// Returns a pair of locations that can be safely coalesced, or `nil` if no such pair is known.
		func safelyCoalescableLocations() -> (AbstractLocation, Location)? {
			switch self {
				
				case .do(let effects, analysisAtEntry: _):
				return effects
						.reversed()
						.lazy
						.compactMap { $0.safelyCoalescableLocations() }
						.first
				
				case .set(_, .abstract(let destination), to: let source, analysisAtEntry: let analysis):
				guard let source = source.location, analysis.safelyCoalescable(source, .abstract(destination)) else { return nil }
				return (destination, source)
					
				case .set(_, let destination, to: .abstract(let source), analysisAtEntry: let analysis):
				guard analysis.safelyCoalescable(.abstract(source), destination) else { return nil }
				return (source, destination)
				
				case .set, .compute, .allocateVector, .getElement, .setElement, .push, .pop, .pushScope, .popScope, .call, .return:
				return nil
				
				case .if(let predicate, then: let affirmative, else: let negative, analysisAtEntry: _):
				return negative.safelyCoalescableLocations()
					?? affirmative.safelyCoalescableLocations()
					?? predicate.safelyCoalescableLocations()
				
			}
		}
		
		/// Returns a copy of `self` where `removedLocation` is coalesced into `retainedLocation` and the effect's analysis at entry is updated accordingly.
		///
		/// - Parameters:
		///   - removedLocation: The location that is replaced by `retainedLocation`.
		///   - retainedLocation: The location that remains.
		///   - declarations: The local declarations.
		///   - analysis: On method entry, analysis at exit of `self`. On method exit, the analysis at entry of `self`.
		///
		/// - Returns: A copy of `self` where `removedLocation` is coalesced into `retainedLocation` and the effect's analysis at entry is updated accordingly.
		func coalescing(
			_ removedLocation:		AbstractLocation,
			into retainedLocation:	Location,
			declarations:			Declarations,
			analysis:				inout Analysis
		) throws -> Self {
			try updated(using: {
				try $0.coalescingLocally(removedLocation, into: retainedLocation, declarations: declarations)
			}, analysis: &analysis)
		}
		
		/// Returns a copy of `self` where `removedLocation` is coalesced into `retainedLocation`, without updating any children effects or analysis information.
		///
		/// This method should be used as part of an `update(using:analysis:)` call which ensures the coalescing is done globally and analysis information is updated appropriately.
		///
		/// - Parameters:
		///   - removedLocation: The location that is replaced by `retainedLocation`.
		///   - retainedLocation: The location that is retained.
		///
		/// - Returns: A copy of `self` where `removedLocation` is coalesced into `retainedLocation`.
		func coalescingLocally(_ removedLocation: AbstractLocation, into retainedLocation: Location, declarations: Declarations) throws -> Self {
			
			func substitute(_ location: Location) -> Location {
				location == .abstract(removedLocation) ? retainedLocation : location
			}
			
			func substitute(_ source: Source) throws -> Source {
				guard source == .abstract(removedLocation) else { return source }
				switch retainedLocation {
					
					case .abstract(let location):
					return .abstract(location)
					
					case .register(let register):
					return try .register(register, declarations[Location.abstract(removedLocation)])
					
					case .frame(let location):
					return .frame(location)
					
				}
			}
			
			switch self {
				
				case .do, .if, .pop, .pushScope, .popScope, .call, .return:
				return self
				
				case .set(_, .abstract(removedLocation), to: let source, analysisAtEntry: let analysis)
					where source.location == retainedLocation || source.location == .abstract(removedLocation):
				return .do([], analysisAtEntry: analysis)
				
				case .set(let type, .abstract(removedLocation), to: let source, analysisAtEntry: let analysis):
				return .set(type, retainedLocation, to: source, analysisAtEntry: analysis)
				
				case .set(_, retainedLocation, to: .abstract(removedLocation), analysisAtEntry: let analysis):
				return .do([], analysisAtEntry: analysis)
				
				case .set(_, retainedLocation, to: let source, analysisAtEntry: let analysis) where source.location == retainedLocation:
				return .do([], analysisAtEntry: analysis)
				
				case .set:
				return self
				
				case .compute(let lhs, let op, let rhs, to: let destination, analysisAtEntry: let analysis):
				return try .compute(substitute(lhs), op, substitute(rhs), to: substitute(destination), analysisAtEntry: analysis)
				
				case .allocateVector(let type, count: let count, into: let vector, analysisAtEntry: let analysis):
				return .allocateVector(type, count: count, into: substitute(vector), analysisAtEntry: analysis)
				
				case .getElement(let type, of: let vector, at: let index, to: let destination, analysisAtEntry: let analysis):
				return try .getElement(type, of: substitute(vector), at: substitute(index), to: substitute(destination), analysisAtEntry: analysis)
				
				case .setElement(let type, of: let vector, at: let index, to: let source, analysisAtEntry: let analysis):
				return try .setElement(type, of: substitute(vector), at: substitute(index), to: substitute(source), analysisAtEntry: analysis)
				
				case .push(let dataType, let source, analysisAtEntry: let analysis):
				return .push(dataType, try substitute(source), analysisAtEntry: analysis)
				
			}
			
		}
		
	}
	
}
