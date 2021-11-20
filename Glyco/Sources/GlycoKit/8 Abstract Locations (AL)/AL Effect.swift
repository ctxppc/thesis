// Glyco © 2021 Constantino Tsarouhas

import DepthKit

extension AL {
	
	/// An effect on an AL machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case sequence(effects: [Effect])
		
		/// An effect that retrieves the value in `source` and puts it in `destination`.
		case copy(destination: Location, source: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `destination`.
		case compute(destination: Location, lhs: Source, operation: BinaryOperator, rhs: Source)
		
		/// An effect that performs `affirmative` if `predicate` holds, or `negative` otherwise.
		indirect case conditional(predicate: Predicate, affirmative: Effect, negative: Effect)
		
		/// An effect that invokes the procedure labelled `procedure` passing `arguments` as the invocation's arguments.
		case invoke(procedure: Label, arguments: [Source])
		
		/// An effect that terminates the program with `result`.
		case `return`(result: Source)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .sequence(effects: let effects):
				return .sequence(effects: try effects.lowered(in: &context))
				
				case .copy(destination: let destination, source: let source):
				return .copy(destination: destination.lowered(in: &context), source: try source.lowered(in: &context))
				
				case .compute(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs):
				return try .compute(
					destination:	destination.lowered(in: &context),
					lhs:			lhs.lowered(in: &context),
					operation:		operation,
					rhs:			rhs.lowered(in: &context)
				)
				
				case .conditional(predicate: let predicate, affirmative: let affirmative, negative: let negative):
				return try .conditional(
					predicate:		predicate.lowered(in: &context),
					affirmative:	affirmative.lowered(in: &context),
					negative:		negative.lowered(in: &context)
				)
				
				case .invoke(procedure: let procedure, arguments: let arguments):
				return .invoke(procedure: procedure, arguments: try arguments.lowered(in: &context))
				
				case .return(result: let result):
				return .return(result: try result.lowered(in: &context))
				
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
				
				case .sequence(effects: let effects):
				(livenessAtEntry, conflictsAtEntry) = effects.reversed().reduce((livenessAtEntry, conflictsAtEntry)) {
					$1.livenessAndConflictsAtEntry(livenessAtExit: $0.0, conflictsAtExit: $0.1)
				}
				
				case .copy, .compute, .invoke, .return:
				break	// already dealt with defined & used locations above
				
				case .conditional(predicate: _ /* already dealt with */, affirmative: let affirmative, negative: let negative):
				let (livenessAtAffirmativeEntry, conflictsAtAffirmativeEntry) =
					affirmative.livenessAndConflictsAtEntry(livenessAtExit: livenessAtExit, conflictsAtExit: conflictsAtExit)
				let (livenessAtNegativeEntry, conflictsAtNegativeEntry) =
					negative.livenessAndConflictsAtEntry(livenessAtExit: livenessAtExit, conflictsAtExit: conflictsAtExit)
				livenessAtEntry.formUnion(with: livenessAtAffirmativeEntry)
				livenessAtEntry.formUnion(with: livenessAtNegativeEntry)
				conflictsAtEntry.formUnion(with: conflictsAtAffirmativeEntry)
				conflictsAtEntry.formUnion(with: conflictsAtNegativeEntry)
				
			}
			
			return (livenessAtEntry, conflictsAtEntry)
			
		}
		
		/// Returns the locations defined by `self`.
		private func definedLocations() -> Set<Location> {
			switch self {
				
				case .sequence, .conditional, .invoke, .return:
				return []
				
				case .copy(destination: let destination, source: _), .compute(destination: let destination, lhs: _, operation: _, rhs: _):
				return [destination]
				
			}
		}
		
		/// Returns the locations possibly used by `self`.
		private func possiblyUsedLocations() -> Set<Location> {
			switch self {
				
				case .sequence,
						.copy(destination: _, source: .immediate),
						.compute(destination: _, lhs: .immediate, operation: _, rhs: .immediate),
						.return(result: .immediate):
				return []
				
				case .copy(destination: _, source: .location(let source)),
						.compute(destination: _, lhs: .immediate, operation: _, rhs: .location(let source)),
						.compute(destination: _, lhs: .location(let source), operation: _, rhs: .immediate),
						.return(result: .location(let source)):
				return [source]
				
				case .compute(destination: _, lhs: .location(let lhs), operation: _, rhs: .location(let rhs)):
				return [lhs, rhs]
				
				case .conditional(predicate: let predicate, affirmative: _, negative: _):
				return predicate.usedLocations()
				
				case .invoke(procedure: _, arguments: let arguments):
				return .init(arguments.compactMap { argument in
					switch argument {
						case .immediate:				return nil
						case .location(let location):	return location
					}
				})
				
			}
		}
		
	}
	
	public typealias BinaryOperator = Lower.BinaryOperator
	
}

public func <- (destination: AL.Location, source: AL.Source) -> AL.Effect {
	.copy(destination: destination, source: source)
}
