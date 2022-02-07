// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// An effect on an ALA machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect], analysisAtEntry: Analysis)
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(DataType, Location, to: Source, analysisAtEntry: Analysis)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location, analysisAtEntry: Analysis)
		
		/// An effect that pushes a vector of `count` elements to the call frame and puts a capability for that vector in `into`.
		case allocateVector(DataType, count: Int = 1, into: Location, analysisAtEntry: Analysis)
		
		/// An effect that retrieves the element at zero-based position `at` in the vector in `of` and puts it in `to`.
		case getElement(DataType, of: Location, at: Source, to: Location, analysisAtEntry: Analysis)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(DataType, of: Location, at: Source, to: Source, analysisAtEntry: Analysis)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect, analysisAtEntry: Analysis)
		
		/// An effect that retrieves the value from given source and pushes it to the call frame.
		case push(DataType, Source, analysisAtEntry: Analysis)
		
		/// An effect that removes `bytes` bytes from the stack.
		case pop(bytes: Int, analysisAtEntry: Analysis)
		
		/// Pushes a new scope (i.e., call frame) to the scope stack (i.e., call stack).
		///
		/// This effect must be executed exactly once before any location defined in the current scope is accessed.
		case pushScope(analysisAtEntry: Analysis)
		
		/// Pops a scope (i.e., call frame) from the scope stack (i.e., call stack).
		///
		/// This effect must be executed exactly once before any location defined in the previous scope is accessed.
		case popScope(analysisAtEntry: Analysis)
		
		/// An effect that invokes the labelled procedure and uses given locations.
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
				try Lowered.set(type, destination.lowered(in: &context), to: source.lowered(in: &context))
				
				case .compute(let lhs, let op, let rhs, to: let destination, analysisAtEntry: _):
				try Lowered.compute(lhs.lowered(in: &context), op, rhs.lowered(in: &context), to: destination.lowered(in: &context))
				
				case .allocateVector(let type, count: let count, into: let vector, analysisAtEntry: _):
				Lowered.allocateVector(type, count: count, into: try vector.lowered(in: &context))
				
				case .getElement(let type, of: let vector, at: let index, to: let destination, analysisAtEntry: _):
				try Lowered.getElement(type, of: vector.lowered(in: &context), at: index.lowered(in: &context), to: destination.lowered(in: &context))
				
				case .setElement(let type, of: let vector, at: let index, to: let source, analysisAtEntry: _):
				try Lowered.setElement(type, of: vector.lowered(in: &context), at: index.lowered(in: &context), to: source.lowered(in: &context))
				
				case .if(let predicate, then: let affirmative, else: let negative, analysisAtEntry: _):
				try Lowered.if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .push(let dataType, let source, analysisAtEntry: _):
				Lowered.push(dataType, try source.lowered(in: &context))
				
				case .pop(bytes: let bytes, analysisAtEntry: _):
				Lowered.pop(bytes: bytes)
				
				case .pushScope(analysisAtEntry: _):
				Lowered.pushFrame(bytes: 0)	// TODO: Pass spill size.
				
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
		func updated(using transform: Transformation, analysis: inout Analysis) -> Self {
			let transformed = transform(self)
			analysis.update(defined: transformed.definedLocations(), possiblyUsed: transformed.possiblyUsedLocations())
			switch transformed {
				
				case .do(let effects, analysisAtEntry: _):
				return .do(
					effects
						.reversed()
						.map { $0.updated(using: transform, analysis: &analysis) }	// update effects in reverse order so that analysis flows backwards
						.reversed(),												// reverse back to normal order
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
					let updatedAffirmative = affirmative.updated(using: transform, analysis: &analysisAtAffirmativeEntry)
					
					let updatedNegative = negative.updated(using: transform, analysis: &analysis)
					analysis.formUnion(with: analysisAtAffirmativeEntry)
					
					let updatedPredicate = predicate.updated(using: transform, analysis: &analysis)
					
					return .if(updatedPredicate, then: updatedAffirmative, else: updatedNegative, analysisAtEntry: analysis)
					
				}
				
				case .push(let dataType, let source, analysisAtEntry: _):
				return .push(dataType, source, analysisAtEntry: analysis)
				
				case .pop(bytes: let bytes, analysisAtEntry: _):
				return .pop(bytes: bytes, analysisAtEntry: analysis)
				
				case .pushScope(bytes: let bytes, analysisAtEntry: _):
				return .pushScope(bytes: bytes, analysisAtEntry: analysis)
				
				case .popScope(analysisAtEntry: _):
				return .popScope(analysisAtEntry: analysis)
				
				case .call(let name, let locations, analysisAtEntry: _):
				return .call(name, locations, analysisAtEntry: analysis)
				
				case .return(analysisAtEntry: _):
				return .return(analysisAtEntry: analysis)
				
			}
		}
		
		/// A function that transforms an effect into the same effect or different effect.
		typealias Transformation = (Self) -> Self
		
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
					.pushScope(bytes: _, analysisAtEntry: let analysis),
					.popScope(analysisAtEntry: let analysis),
					.call(_, _, analysisAtEntry: let analysis),
					.return(analysisAtEntry: let analysis):
				return analysis
			}
		}
		
		/// Returns the locations defined by `self`.
		private func definedLocations() -> Set<Location> {
			switch self {
				
				case .do, .setElement, .if, .push, .pop, .pushScope, .popScope, .call, .return:
				return []
				
				case .set(_, let destination, to: _, analysisAtEntry: _),
					.compute(_, _, _, to: let destination, analysisAtEntry: _),
					.allocateVector(_, count: _, into: let destination, analysisAtEntry: _),
					.getElement(_, of: _, at: _, to: let destination, analysisAtEntry: _):
				return [destination]
				
			}
		}
		
		/// Returns the locations possibly used by `self`.
		private func possiblyUsedLocations() -> Set<Location> {
			switch self {
				
				case .do,
					.set(_, _, to: .constant, analysisAtEntry: _),
					.compute(.constant, _, .constant, to: _, analysisAtEntry: _),
					.allocateVector,
					.if,
					.push(_, .constant, analysisAtEntry: _),
					.pop,
					.pushScope,
					.popScope,
					.return:
				return []
				
				case .set(_, _, to: .location(let source), analysisAtEntry: _),
					.compute(.constant, _, .location(let source), to: _, analysisAtEntry: _),
					.compute(.location(let source), _, .constant, to: _, analysisAtEntry: _),
					.push(_, .location(let source), analysisAtEntry: _):
				return [source]
				
				case .compute(.location(let lhs), _, .location(let rhs), to: _, analysisAtEntry: _):
				return [lhs, rhs]
				
				case .getElement(_, of: let vector, at: .constant, to: _, analysisAtEntry: _),
					.setElement(_, of: let vector, at: .constant, to: _, analysisAtEntry: _):
				return [vector]
				
				case .getElement(_, of: let vector, at: .location(let index), to: _, analysisAtEntry: _),
					.setElement(_, of: let vector, at: .location(let index), to: _, analysisAtEntry: _):
				return [vector, index]
				
				case .call(_, let arguments, analysisAtEntry: _):
				return .init(arguments.map { $0 })
				
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
				
				case .set(_, .abstract(let destination), to: .location(let source), analysisAtEntry: let analysis)
					where analysis.safelyCoalescable(.abstract(destination), source):
				return (destination, source)
					
				case .set(_, let destination, to: .location(.abstract(let source)), analysisAtEntry: let analysis)
					where analysis.safelyCoalescable(destination, .abstract(source)):
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
		///   - analysis: On method entry, analysis at exit of `self`. On method exit, the analysis at entry of `self`.
		///
		/// - Returns: A copy of `self` where `removedLocation` is coalesced into `retainedLocation` and the effect's analysis at entry is updated accordingly.
		func coalescing(_ removedLocation: AbstractLocation, into retainedLocation: Location, analysis: inout Analysis) -> Self {
			updated(using: { $0.coalescingLocally(removedLocation, into: retainedLocation) }, analysis: &analysis)
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
		func coalescingLocally(_ removedLocation: AbstractLocation, into retainedLocation: Location) -> Self {
			
			func substitute(_ location: Location) -> Location {
				location == .abstract(removedLocation) ? retainedLocation : location
			}
			
			func substitute(_ source: Source) -> Source {
				source == .location(.abstract(removedLocation)) ? .location(retainedLocation) : source
			}
			
			switch self {
				
				case .do, .if, .pop, .pushScope, .popScope, .call, .return:
				return self
				
				case .set(_, .abstract(removedLocation), to: .location(retainedLocation), analysisAtEntry: let analysis),
					.set(_, retainedLocation, to: .location(.abstract(removedLocation)), analysisAtEntry: let analysis),
					.set(_, retainedLocation, to: .location(retainedLocation), analysisAtEntry: let analysis),
					.set(_, .abstract(removedLocation), to: .location(.abstract(removedLocation)), analysisAtEntry: let analysis):
				return .do([], analysisAtEntry: analysis)
				
				case .set(let type, .abstract(removedLocation), to: let source, analysisAtEntry: let analysis):
				return .set(type, retainedLocation, to: source, analysisAtEntry: analysis)
				
				case .set:
				return self
				
				case .compute(let lhs, let op, let rhs, to: let destination, analysisAtEntry: let analysis):
				return .compute(substitute(lhs), op, substitute(rhs), to: substitute(destination), analysisAtEntry: analysis)
				
				case .allocateVector(let type, count: let count, into: let vector, analysisAtEntry: let analysis):
				return .allocateVector(type, count: count, into: substitute(vector), analysisAtEntry: analysis)
				
				case .getElement(let type, of: let vector, at: let index, to: let destination, analysisAtEntry: let analysis):
				return .getElement(type, of: substitute(vector), at: substitute(index), to: substitute(destination), analysisAtEntry: analysis)
				
				case .setElement(let type, of: let vector, at: let index, to: let source, analysisAtEntry: let analysis):
				return .setElement(type, of: substitute(vector), at: substitute(index), to: substitute(source), analysisAtEntry: analysis)
				
				case .push(let dataType, let source, analysisAtEntry: let analysis):
				return .push(dataType, substitute(source), analysisAtEntry: analysis)
				
			}
			
		}
		
	}
	
}
