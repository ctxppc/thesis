// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit

extension AL {
	
	/// An effect on an AL machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(DataType, Location, to: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
		/// An effect that retrieves the element at zero-based position `at` in the vector in `of` and puts it in `to`.
		case getElement(DataType, of: Location, at: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(DataType, of: Location, at: Source, to: Source)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect)
		
		/// An effect that invokes the labelled procedure and uses given locations.
		///
		/// This effect assumes a suitable calling convention has already been applied to the program. The parameter locations are only used for the purposes of liveness analysis.
		case call(Label, [ParameterLocation])
		
		/// An effect that terminates the program with `result`.
		case `return`(DataType, Source)
		
		// See protocol.
		func lowered(in context: inout LocalContext) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects):
				return .do(try effects.lowered(in: &context))
				
				case .set(let type, let destination, to: let source):
				return try .set(type, destination.lowered(in: &context), to: source.lowered(in: &context))
				
				case .compute(let lhs, let operation, let rhs, to: let destination):
				return try .compute(lhs.lowered(in: &context), operation, rhs.lowered(in: &context), to: destination.lowered(in: &context))
				
				case .getElement(let type, of: let vector, at: let index, to: let destination):
				return try .getElement(type, of: vector.lowered(in: &context), at: index.lowered(in: &context), to: destination.lowered(in: &context))
				
				case .setElement(let type, of: let vector, at: let index, to: let element):
				return try .setElement(type, of: vector.lowered(in: &context), at: index.lowered(in: &context), to: element.lowered(in: &context))
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .call(let procedure, _):
				return .call(procedure)
				
				case .return(let type, let result):
				return .return(type, try result.lowered(in: &context))
				
			}
		}
		
		/// Returns a tuple consisting of (1) a set partitioning locations whose current value is either possibly used or definitely not used at the point *right before* executing `self` and (2) an undirected graph of locations who are connected iff they simultaneously hold a value that is possibly needed by an effect executed in the future.
		///
		/// - Parameter livenessAtExit: The liveness set right after executing `self`.
		/// - Parameter conflictsAtExit: The conflict graph right after executing `self`.
		func livenessAndConflictsAtEntry(livenessAtExit: LivenessSet, conflictsAtExit: ConflictGraph) -> (LivenessSet, ConflictGraph) {
			
			var livenessAtEntry = livenessAtExit
			let definedLocations = definedLocations()
			livenessAtEntry.markAsDefinitelyDiscarded(definedLocations)			// with this ordering,
			livenessAtEntry.markAsPossiblyUsedLater(possiblyUsedLocations())	// copy to self or compute in-place becomes possibly-used-later
			
			var conflictsAtEntry = conflictsAtExit
			for definedLocation in definedLocations {
				conflictsAtEntry.insertConflict(definedLocation, livenessAtExit.possiblyAliveLocations)
			}
			
			switch self {
				
				case .do(effects: let effects):
				(livenessAtEntry, conflictsAtEntry) = effects.reversed().reduce((livenessAtEntry, conflictsAtEntry)) {
					$1.livenessAndConflictsAtEntry(livenessAtExit: $0.0, conflictsAtExit: $0.1)
				}
				
				case .set, .compute, .getElement, .setElement, .call, .return:
				break	// already dealt with defined & used locations above
				
				case .if(let predicate, then: let affirmative, else: let negative):
				let (livenessAtAffirmativeEntry, conflictsAtAffirmativeEntry) =
					affirmative.livenessAndConflictsAtEntry(livenessAtExit: livenessAtExit, conflictsAtExit: conflictsAtExit)
				let (livenessAtNegativeEntry, conflictsAtNegativeEntry) =
					negative.livenessAndConflictsAtEntry(livenessAtExit: livenessAtExit, conflictsAtExit: conflictsAtExit)
				let livenessAtBodyEntry = livenessAtAffirmativeEntry.union(livenessAtNegativeEntry)
				let conflictsAtBodyEntry = conflictsAtAffirmativeEntry.union(conflictsAtNegativeEntry)
				(livenessAtEntry, conflictsAtEntry)
					= predicate.livenessAndConflictsAtEntry(livenessAtExit: livenessAtBodyEntry, conflictsAtExit: conflictsAtBodyEntry)
				
			}
			
			return (livenessAtEntry, conflictsAtEntry)
			
		}
		
		/// Returns the locations defined by `self`.
		private func definedLocations() -> Set<Location> {
			switch self {
				
				case .do, .setElement, .if, .call, .return:
				return []
				
				case .set(_, let destination, to: _),
						.compute(_, _, _, to: let destination),
						.getElement(_, of: _, at: _, to: let destination):
				return [destination]
				
			}
		}
		
		/// Returns the locations possibly used by `self`.
		private func possiblyUsedLocations() -> Set<Location> {
			switch self {
				
				case .do,
						.set(_, _, to: .immediate),
						.compute(.immediate, _, .immediate, to: _),
						.if,
						.return(_, .immediate):
				return []
				
				case .set(_, _, to: .location(let source)),
						.compute(.immediate, _, .location(let source), to: _),
						.compute(.location(let source), _, .immediate, to: _),
						.return(_, .location(let source)):
				return [source]
				
				case .compute(.location(let lhs), _, .location(let rhs), to: _):
				return [lhs, rhs]
				
				case .getElement(_, of: let vector, at: .immediate, to: _),
						.setElement(_, of: let vector, at: .immediate, to: _):
				return [vector]
				
				case .getElement(_, of: let vector, at: .location(let index), to: _),
						.setElement(_, of: let vector, at: .location(let index), to: _):
				return [vector, index]
				
				case .call(_, let arguments):
				return .init(arguments.map { .parameter($0) })
				
			}
		}
		
	}
	
}
