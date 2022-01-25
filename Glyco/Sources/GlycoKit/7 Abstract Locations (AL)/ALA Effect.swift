// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit

extension ALA {
	
	/// An effect on an ALA machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect], analysisAtEntry: Analysis)
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(DataType, Location, to: Source, analysisAtEntry: Analysis)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location, analysisAtEntry: Analysis)
		
		/// An effect that retrieves the element at zero-based position `at` in the vector in `of` and puts it in `to`.
		case getElement(DataType, of: Location, at: Source, to: Location, analysisAtEntry: Analysis)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(DataType, of: Location, at: Source, to: Source, analysisAtEntry: Analysis)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect, analysisAtEntry: Analysis)
		
		/// An effect that invokes the labelled procedure and uses given locations.
		///
		/// This effect assumes a suitable calling convention has already been applied to the program. The parameter locations are only used for the purposes of liveness analysis.
		case call(Label, [ParameterLocation], analysisAtEntry: Analysis)
		
		/// An effect that terminates the program with `result`.
		case `return`(DataType, Source, analysisAtEntry: Analysis)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects, analysisAtEntry: _):
				return .do(try effects.lowered(in: &context))
				
				case .set(let dataType, let destination, to: let source, analysisAtEntry: _):
				return try .set(dataType, destination.lowered(in: &context), to: source.lowered(in: &context))
				
				case .compute(let lhs, let op, let rhs, to: let destination, analysisAtEntry: _):
				return try .compute(lhs.lowered(in: &context), op, rhs.lowered(in: &context), to: destination.lowered(in: &context))
				
				case .getElement(let dataType, of: let vector, at: let index, to: let destination, analysisAtEntry: _):
				return try .getElement(dataType, of: vector.lowered(in: &context), at: index.lowered(in: &context), to: destination.lowered(in: &context))
				
				case .setElement(let dataType, of: let vector, at: let index, to: let source, analysisAtEntry: _):
				return try .setElement(dataType, of: vector.lowered(in: &context), at: index.lowered(in: &context), to: source.lowered(in: &context))
				
				case .if(let predicate, then: let affirmative, else: let negative, analysisAtEntry: _):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .call(let name, _, analysisAtEntry: _):
				return .call(name)
				
				case .return(let dataType, let value, analysisAtEntry: _):
				return .return(dataType, try value.lowered(in: &context))
				
			}
		}
		
		/// Returns a (possibly) transformed copy of `self` with updated analysis at entry.
		///
		/// The transformation is applied first. If the transformed effect contains children, it is applied to those children as well.
		///
		/// - Parameters:
		///    - transform: A function that transforms effects. The default function returns the provided effect unaltered.
		///    - analysis: On method entry, analysis at exit of `self`. On method exit, the analysis at entry of `self`.
		///
		/// - Returns: `transform(self)` with updated analysis at entry.
		func updated(using transform: Transformation = { $0 }, analysis: inout Analysis) -> Self {
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
				
				case .getElement(let type, of: let vector, at: let index, to: let destination, analysisAtEntry: _):
				return .getElement(type, of: vector, at: index, to: destination, analysisAtEntry: analysis)
				
				case .setElement(let type, of: let vector, at: let index, to: let element, analysisAtEntry: _):
				return .setElement(type, of: vector, at: index, to: element, analysisAtEntry: analysis)
				
				case .if(let predicate, then: let affirmative, else: let negative, analysisAtEntry: _):
				do {
					
					/*						 │
					┌────────────────────────┼────────────────────────┐
					│    ┌───────────────────▼───────────────────┐    │
					│    │                                       │    │
					│    │               Predicate               │    │
					│    │                                       │    │
					│    └───────┬───────────────────────┬───────┘    │
					│ analysisAtA│firmativeEntry         │            │
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
					let updatedAffirmative = affirmative.updated(analysis: &analysisAtAffirmativeEntry)
					
					let updatedNegative = negative.updated(analysis: &analysis)
					analysis.formUnion(with: analysisAtAffirmativeEntry)
					
					let updatedPredicate = predicate.updated(analysis: &analysis)
					
					return .if(updatedPredicate, then: updatedAffirmative, else: updatedNegative, analysisAtEntry: analysis)
					
				}
				
				case .call(let name, let locations, analysisAtEntry: _):
				return .call(name, locations, analysisAtEntry: analysis)
				
				case .return(let type, let result, analysisAtEntry: _):
				return .return(type, result, analysisAtEntry: analysis)
				
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
					.getElement(_, of: _, at: _, to: _, analysisAtEntry: let analysis),
					.setElement(_, of: _, at: _, to: _, analysisAtEntry: let analysis),
					.if(_, then: _, else: _, analysisAtEntry: let analysis),
					.call(_, _, analysisAtEntry: let analysis),
					.return(_, _, analysisAtEntry: let analysis):
				return analysis
			}
		}
		
		/// Returns the locations defined by `self`.
		private func definedLocations() -> Set<Location> {
			switch self {
				
				case .do, .setElement, .if, .call, .return:
				return []
				
				case .set(_, let destination, to: _, analysisAtEntry: _),
					.compute(_, _, _, to: let destination, analysisAtEntry: _),
					.getElement(_, of: _, at: _, to: let destination, analysisAtEntry: _):
				return [destination]
				
			}
		}
		
		/// Returns the locations possibly used by `self`.
		private func possiblyUsedLocations() -> Set<Location> {
			switch self {
				
				case .do,
					.set(_, _, to: .immediate, analysisAtEntry: _),
					.compute(.immediate, _, .immediate, to: _, analysisAtEntry: _),
					.if,
					.return(_, .immediate, analysisAtEntry: _):
				return []
				
				case .set(_, _, to: .location(let source), analysisAtEntry: _),
					.compute(.immediate, _, .location(let source), to: _, analysisAtEntry: _),
					.compute(.location(let source), _, .immediate, to: _, analysisAtEntry: _),
					.return(_, .location(let source), analysisAtEntry: _):
				return [source]
				
				case .compute(.location(let lhs), _, .location(let rhs), to: _, analysisAtEntry: _):
				return [lhs, rhs]
				
				case .getElement(_, of: let vector, at: .immediate, to: _, analysisAtEntry: _),
					.setElement(_, of: let vector, at: .immediate, to: _, analysisAtEntry: _):
				return [vector]
				
				case .getElement(_, of: let vector, at: .location(let index), to: _, analysisAtEntry: _),
					.setElement(_, of: let vector, at: .location(let index), to: _, analysisAtEntry: _):
				return [vector, index]
				
				case .call(_, let arguments, analysisAtEntry: _):
				return .init(arguments.map { .parameter($0) })
				
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
				
				case .set, .compute, .getElement, .setElement, .call, .return:
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
				
				case .do, .if, .call:
				return self
				
				case .set(_, .abstract(removedLocation), to: .location(retainedLocation), analysisAtEntry: let analysis),
					.set(_, retainedLocation, to: .location(.abstract(removedLocation)), analysisAtEntry: let analysis),
					.set(_, retainedLocation, to: .location(retainedLocation), analysisAtEntry: let analysis),
					.set(_, .abstract(removedLocation), to: .location(.abstract(removedLocation)), analysisAtEntry: let analysis):
				return .do([], analysisAtEntry: analysis)
				
				case .set(let dataType, .abstract(removedLocation), to: let source, analysisAtEntry: let analysis):
				return .set(dataType, retainedLocation, to: source, analysisAtEntry: analysis)
				
				case .set:
				return self
				
				case .compute(let lhs, let op, let rhs, to: let destination, analysisAtEntry: let analysis):
				return .compute(substitute(lhs), op, substitute(rhs), to: substitute(destination), analysisAtEntry: analysis)
				
				case .getElement(let dataType, of: let vector, at: let index, to: let destination, analysisAtEntry: let analysis):
				return .getElement(dataType, of: substitute(vector), at: substitute(index), to: substitute(destination), analysisAtEntry: analysis)
				
				case .setElement(let dataType, of: let vector, at: let index, to: let source, analysisAtEntry: let analysis):
				return .setElement(dataType, of: substitute(vector), at: substitute(index), to: substitute(source), analysisAtEntry: analysis)
				
				case .return(let dataType, let value, analysisAtEntry: let analysis):
				return .return(dataType, substitute(value), analysisAtEntry: analysis)
				
			}
			
		}
		
	}
	
}
