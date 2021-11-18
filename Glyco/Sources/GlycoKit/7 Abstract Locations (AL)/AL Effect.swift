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
		
		/// An effect that terminates the program with `result`.
		case `return`(result: Source)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {

				case .sequence(effects: let effects):
				return .sequence(effects: try effects.lowered(in: &context))

				case .copy(destination: let destination, source: let source):
				return .copy(destination: destination.lowered(in: &context), source: source.lowered(in: &context))

				case .compute(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs):
				return .compute(
					destination:	destination.lowered(in: &context),
					lhs:			lhs.lowered(in: &context),
					operation:		operation,
					rhs:			rhs.lowered(in: &context)
				)

				case .conditional(predicate: let predicate, affirmative: let affirmative, negative: let negative):
				return .conditional(
					predicate:		predicate.lowered(in: &context),
					affirmative:	try affirmative.lowered(in: &context),
					negative:		try negative.lowered(in: &context)
				)

				case .return(result: let result):
				return .return(result: result.lowered(in: &context))

			}
		}
		
		/// Returns a tuple consisting of (1) a set partitioning locations whose current value is either possibly used or definitely not used at the point *right before* executing `self` and (2) an undirected graph of locations who are connected iff they simultaneously hold a value that is possibly needed by an effect executed in the future.
		///
		/// - Parameter livenessAtExit: The liveness set right after executing `self`.
		/// - Parameter conflictsAtExit: The conflict graph right after executing `self`.
		func livenessAndConflictsAtEntry(livenessAtExit: LivenessSet, conflictsAtExit: ConflictGraph) -> (LivenessSet, ConflictGraph) {
			var livenessAtEntry = livenessAtExit
			var conflictsAtEntry = conflictsAtExit
			switch self {
				
				case .sequence(effects: let effects):
				(livenessAtEntry, conflictsAtEntry) = effects.reversed().reduce((livenessAtEntry, conflictsAtEntry)) {
					$1.livenessAndConflictsAtEntry(livenessAtExit: $0.0, conflictsAtExit: $0.1)
				}
				
				case .copy(destination: let destination, source: .location(let source)):
				livenessAtEntry[destination] = .definitelyDiscarded	// value from predecessors is being overwritten and thus cannot possibly be used by successors
				livenessAtEntry[source] = .possiblyUsedLater		// source value is used if (it turns out that) the destination value is also used
				conflictsAtEntry.insertConflict(destination, livenessAtExit.possiblyAliveLocations)
				
				case .copy(destination: let destination, source: .immediate):
				livenessAtEntry[destination] = .definitelyDiscarded	// value from predecessors is being overwritten and thus cannot possibly be used by successors
				conflictsAtEntry.insertConflict(destination, livenessAtExit.possiblyAliveLocations)
				
				case .compute(destination: let destination, lhs: let lhs, operation: _, rhs: let rhs):
				livenessAtEntry[destination] = .definitelyDiscarded	// value from predecessors is being overwritten and thus cannot possibly be used by successors
				if case .location(let lhs) = lhs {
					livenessAtEntry[lhs] = .possiblyUsedLater		// lhs value is used if (it turns out that) the destination value is also used
				}
				if case .location(let rhs) = rhs {
					livenessAtEntry[rhs] = .possiblyUsedLater		// rhs value is used if (it turns out that) the destination value is also used
				}
				conflictsAtEntry.insertConflict(destination, livenessAtExit.possiblyAliveLocations)
				
				case .conditional(predicate: let predicate, affirmative: let affirmative, negative: let negative):
				let (livenessAtAffirmativeEntry, conflictsAtAffirmativeEntry) =
					affirmative.livenessAndConflictsAtEntry(livenessAtExit: livenessAtExit, conflictsAtExit: conflictsAtExit)
				let (livenessAtNegativeEntry, conflictsAtNegativeEntry) =
					negative.livenessAndConflictsAtEntry(livenessAtExit: livenessAtExit, conflictsAtExit: conflictsAtExit)
				for location in predicate.usedLocations() {
					livenessAtEntry[location] = .possiblyUsedLater
				}
				livenessAtEntry.formUnion(with: livenessAtAffirmativeEntry)
				livenessAtEntry.formUnion(with: livenessAtNegativeEntry)
				conflictsAtEntry.formUnion(with: conflictsAtAffirmativeEntry)
				conflictsAtEntry.formUnion(with: conflictsAtNegativeEntry)
				
				case .return(result: .location(let source)):
				livenessAtEntry[source] = .possiblyUsedLater
				
				case .return(result: .immediate):
				break
				
			}
			return (livenessAtEntry, conflictsAtEntry)
		}
		
	}
	
	public typealias BinaryOperator = Lower.BinaryOperator
	
}

public func <- (destination: AL.Location, source: AL.Source) -> AL.Effect {
	.copy(destination: destination, source: source)
}
