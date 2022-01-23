// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit

extension ALA {
	
	/// An effect on an ALA machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect], Analysis)
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(DataType, Location, to: Source, Analysis)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location, Analysis)
		
		/// An effect that retrieves the element at zero-based position `at` in the vector in `of` and puts it in `to`.
		case getElement(DataType, of: Location, at: Source, to: Location, Analysis)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(DataType, of: Location, at: Source, to: Source, Analysis)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect, Analysis)
		
		/// An effect that invokes the labelled procedure and uses given locations.
		///
		/// This effect assumes a suitable calling convention has already been applied to the program. The parameter locations are only used for the purposes of liveness analysis.
		case call(Label, [ParameterLocation], Analysis)
		
		/// An effect that terminates the program with `result`.
		case `return`(DataType, Source, Analysis)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects, _):
				return .do(try effects.lowered(in: &context))
				
				case .set(let dataType, let destination, to: let source, _):
				return try .set(dataType, destination.lowered(in: &context), to: source.lowered(in: &context))
				
				case .compute(let lhs, let op, let rhs, to: let destination, _):
				return try .compute(lhs.lowered(in: &context), op, rhs.lowered(in: &context), to: destination.lowered(in: &context))
				
				case .getElement(let dataType, of: let vector, at: let index, to: let destination, _):
				return try .getElement(dataType, of: vector.lowered(in: &context), at: index.lowered(in: &context), to: destination.lowered(in: &context))
				
				case .setElement(let dataType, of: let vector, at: let index, to: let source, _):
				return try .setElement(dataType, of: vector.lowered(in: &context), at: index.lowered(in: &context), to: source.lowered(in: &context))
				
				case .if(let predicate, then: let affirmative, else: let negative, _):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .call(let name, _, _):
				return .call(name)
				
				case .return(let dataType, let value, _):
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
				
				case .do(let effects, _):
				return .do(
					effects
						.reversed()
						.map { $0.updated(using: transform, analysis: &analysis) }	// update effects in reverse order so that analysis flows backwards
						.reversed(),												// reverse back to normal order
					analysis
				)
				
				case .set(let type, let destination, to: let source, _):
				return .set(type, destination, to: source, analysis)
				
				case .compute(let lhs, let operation, let rhs, to: let destination, _):
				return .compute(lhs, operation, rhs, to: destination, analysis)
				
				case .getElement(let type, of: let vector, at: let index, to: let destination, _):
				return .getElement(type, of: vector, at: index, to: destination, analysis)
				
				case .setElement(let type, of: let vector, at: let index, to: let element, _):
				return .setElement(type, of: vector, at: index, to: element, analysis)
				
				case .if(let predicate, then: let affirmative, else: let negative, _):
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
					
					return .if(updatedPredicate, then: updatedAffirmative, else: updatedNegative, analysis)
					
				}
				
				case .call(let name, let locations, _):
				return .call(name, locations, analysisAtEntry)
				
				case .return(let type, let result, _):
				return .return(type, result, analysisAtEntry)
				
			}
		}
		
		/// A function that transforms an effect into the same effect or different effect.
		typealias Transformation = (Self) -> Self
		
		/// The analysis of `self` at entry.
		var analysisAtEntry: Analysis {
			switch self {
				case .do(_, let analysis),
					.set(_, _, to: _, let analysis),
					.compute(_, _, _, to: _, let analysis),
					.getElement(_, of: _, at: _, to: _, let analysis),
					.setElement(_, of: _, at: _, to: _, let analysis),
					.if(_, then: _, else: _, let analysis),
					.call(_, _, let analysis),
					.return(_, _, let analysis):
				return analysis
			}
		}
		
		/// Returns the locations defined by `self`.
		private func definedLocations() -> Set<Location> {
			switch self {
				
				case .do, .setElement, .if, .call, .return:
				return []
				
				case .set(_, let destination, to: _, _),
					.compute(_, _, _, to: let destination, _),
					.getElement(_, of: _, at: _, to: let destination, _):
				return [destination]
				
			}
		}
		
		/// Returns the locations possibly used by `self`.
		private func possiblyUsedLocations() -> Set<Location> {
			switch self {
				
				case .do,
					.set(_, _, to: .immediate, _),
					.compute(.immediate, _, .immediate, to: _, _),
					.if,
					.return(_, .immediate, _):
				return []
				
				case .set(_, _, to: .location(let source), _),
					.compute(.immediate, _, .location(let source), to: _, _),
					.compute(.location(let source), _, .immediate, to: _, _),
					.return(_, .location(let source), _):
				return [source]
				
				case .compute(.location(let lhs), _, .location(let rhs), to: _, _):
				return [lhs, rhs]
				
				case .getElement(_, of: let vector, at: .immediate, to: _, _),
					.setElement(_, of: let vector, at: .immediate, to: _, _):
				return [vector]
				
				case .getElement(_, of: let vector, at: .location(let index), to: _, _),
					.setElement(_, of: let vector, at: .location(let index), to: _, _):
				return [vector, index]
				
				case .call(_, let arguments, _):
				return .init(arguments.map { .parameter($0) })
				
			}
		}
		
		/// Returns a pair of locations that can be safely coalesced, or `nil` if no such pair is known.
		func safelyCoalescableLocations() -> (Location, Location)? {
			switch self {
				
				case .do(let effects, _):
				return effects
						.reversed()
						.lazy
						.compactMap { $0.safelyCoalescableLocations() }
						.first
				
				case .set(_, let destination, to: .location(let source), let analysis) where analysis.safelyCoalescable(destination, source):
				return (destination, source)
				
				case .set, .compute, .getElement, .setElement, .call, .return:
				return nil
				
				case .if(let predicate, then: let affirmative, else: let negative, _):
				return negative.safelyCoalescableLocations()
					?? affirmative.safelyCoalescableLocations()
					?? predicate.safelyCoalescableLocations()
				
			}
		}
		
		/// Returns a copy of `self` where `removedLocation` is coalesced into `remainingLocation` and the effect's analysis at entry is updated accordingly.
		///
		/// - Parameters:
		///   - removedLocation: The location that is replaced by `remainingLocation`.
		///   - remainingLocation: The location that remains.
		///   - analysis: On method entry, analysis at exit of `self`. On method exit, the analysis at entry of `self`.
		///
		/// - Returns: A copy of `self` where `removedLocation` is coalesced into `remainingLocation` and the effect's analysis at entry is updated accordingly.
		func coalescing(_ removedLocation: Location, into remainingLocation: Location, analysis: inout Analysis) -> Self {
			updated(using: { $0.coalescingLocally(removedLocation, into: remainingLocation) }, analysis: &analysis)
		}
		
		/// Returns a copy of `self` where `removedLocation` is coalesced into `remainingLocation`, without updating any children effects or analysis information.
		///
		/// This method should be used as part of an `update(using:analysis:)` call which ensures the coalescing is done globally and analysis information is updated appropriately.
		///
		/// - Parameters:
		///   - removedLocation: The location that is replaced by `remainingLocation`.
		///   - remainingLocation: The location that remains.
		///
		/// - Returns: A copy of `self` where `removedLocation` is coalesced into `remainingLocation`.
		func coalescingLocally(_ removedLocation: Location, into remainingLocation: Location) -> Self {
			
			func substitute(_ location: Location) -> Location {
				location == removedLocation ? remainingLocation : location
			}
			
			func substitute(_ source: Source) -> Source {
				source == .location(removedLocation) ? .location(remainingLocation) : source
			}
			
			switch self {
				
				case .do, .if, .call:
				return self
				
				case .set(_, removedLocation, to: .location(remainingLocation), let analysis),
					.set(_, remainingLocation, to: .location(removedLocation), let analysis),
					.set(_, remainingLocation, to: .location(remainingLocation), let analysis),
					.set(_, removedLocation, to: .location(removedLocation), let analysis):
				return .do([], analysis)
				
				case .set(let dataType, removedLocation, to: let source, let analysis):
				return .set(dataType, remainingLocation, to: source, analysis)
				
				case .set:
				return self
				
				case .compute(let lhs, let op, let rhs, to: let destination, let analysis):
				return .compute(substitute(lhs), op, substitute(rhs), to: substitute(destination), analysis)
				
				case .getElement(let dataType, of: let vector, at: let index, to: let destination, let analysis):
				return .getElement(dataType, of: substitute(vector), at: substitute(index), to: substitute(destination), analysis)
				
				case .setElement(let dataType, of: let vector, at: let index, to: let source, let analysis):
				return .setElement(dataType, of: substitute(vector), at: substitute(index), to: substitute(source), analysis)
				
				case .return(let dataType, let value, let analysis):
				return .return(dataType, substitute(value), analysis)
				
			}
			
		}
		
	}
	
}
