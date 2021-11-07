// Glyco © 2021 Constantino Tsarouhas

import DepthKit

extension AL {
	
	/// An effect on an AL machine.
	public enum Effect : Codable, SimplyLowerable {
		
		/// An effect that does nothing.
		case none
		
		/// An effect that retrieves the value in `source` and puts it in `destination`, then performs `successor`.
		indirect case copy(destination: Location, source: Source, successor: Effect)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `destination`, then performs `successor`.
		indirect case compute(destination: Location, lhs: Source, operation: BinaryOperator, rhs: Source, successor: Effect)
		
		/// An effect that performs `affirmative` if `predicate` holds, or `negative` otherwise, then performs `successor`.
		indirect case conditional(predicate: Predicate, affirmative: Effect, negative: Effect, successor: Effect)
		
		/// An effect that terminates with `result`.
		case `return`(result: Source)
		
		// See protocol.
		func lowered(in context: inout Context) -> Lower.Effect {
			switch self {
				
				case .none:
				return .none
				
				case .copy(destination: let destination, source: let source, successor: let successor):
				return .copy(
					destination:	destination.lowered(in: &context),
					source:			source.lowered(in: &context),
					successor:		successor.lowered(in: &context)
				)
				
				case .compute(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs, successor: let successor):
				return .compute(
					destination:	destination.lowered(in: &context),
					lhs:			lhs.lowered(in: &context),
					operation:		operation,
					rhs:			rhs.lowered(in: &context),
					successor:		successor.lowered(in: &context)
				)
				
				case .conditional(predicate: let predicate, affirmative: let affirmative, negative: let negative, successor: let successor):
				return .conditional(
					predicate:		predicate.lowered(in: &context),
					affirmative:	affirmative.lowered(in: &context),
					negative:		negative.lowered(in: &context),
					successor:		successor.lowered(in: &context)
				)
				
				case .return(result: let result):
				return .return(result: result.lowered(in: &context))
				
			}
		}
		
		/// Returns an undirected graph of locations connected iff they simultaneously hold a value that is possibly used by successors.
		func conflicts() -> ConflictGraph {
			livenessAtEntryAndConflicts().1
		}
		
		/// Returns a tuple consisting of (1) a set partitioning locations whose current value is either possibly used or definitely not used at the point *right before* executing `self` and (2) an undirected graph of locations connected iff they simultaneously hold a value that is possibly used by successors.
		private func livenessAtEntryAndConflicts() -> (LivenessSet, ConflictGraph) {
			let livenessAtEntry: LivenessSet
			let conflicts: ConflictGraph
			switch self {
				
				case .none:
				livenessAtEntry = .nothingUsed
				conflicts = .conflictFree
				
				case .copy(destination: let destination, source: .location(let source), successor: let successor):
				let (livenessAtExit, conflictsInSuccessor) = successor.livenessAtEntryAndConflicts()
				livenessAtEntry = with(livenessAtExit) {
					$0[destination] = .definitelyDiscarded	// value from predecessors is being overwritten and thus cannot possibly be used by successors
					$0[source] = .possiblyUsedLater			// source value is *actually* used iff destination value is also *actually* used (but we can't know)
				}
				conflicts = with(conflictsInSuccessor) {
					$0.insertConflict(destination, livenessAtExit.possiblyAliveLocations.subtracting([source]))	// source value equals destination value at this stage
				}
				
				case .copy(destination: let destination, source: .immediate, successor: let successor):
				let (livenessAtExit, conflictsInSuccessor) = successor.livenessAtEntryAndConflicts()
				livenessAtEntry = with(livenessAtExit) {
					$0[destination] = .definitelyDiscarded	// value from predecessors is being overwritten and thus cannot possibly be used by successors
				}
				conflicts = with(conflictsInSuccessor) {
					$0.insertConflict(destination, livenessAtExit.possiblyAliveLocations)
				}
				
				case .compute(destination: let destination, lhs: let lhs, operation: _, rhs: let rhs, successor: let successor):
				let (livenessAtExit, conflictsInSuccessor) = successor.livenessAtEntryAndConflicts()
				livenessAtEntry = with(livenessAtExit) {
					$0[destination] = .definitelyDiscarded	// value from predecessors is being overwritten and thus cannot possibly be used by successors
					if case .location(let lhs) = lhs {
						$0[lhs] = .definitelyDiscarded		// lhs value is *actually* used iff destination value is also *actually* used (but we can't know)
					}
					if case .location(let rhs) = rhs {
						$0[rhs] = .definitelyDiscarded		// rhs value is *actually* used iff destination value is also *actually* used (but we can't know)
					}
				}
				conflicts = with(conflictsInSuccessor) {
					$0.insertConflict(destination, livenessAtExit.possiblyAliveLocations)
				}
				
				case .conditional(predicate: let predicate, affirmative: let affirmative, negative: let negative, successor: let successor):
				let (livenessAtSuccessorEntry, conflictsInSuccessor) = successor.livenessAtEntryAndConflicts()
				let (livenessAtAffirmativeBranchEntry, conflictsInAffirmative) = affirmative.livenessAtEntryAndConflicts()
				let (livenessAtNegativeBranchEntry, conflictsInNegative) = negative.livenessAtEntryAndConflicts()
				livenessAtEntry = with(livenessAtSuccessorEntry) {
					for location in predicate.usedLocations() {
						$0[location] = .possiblyUsedLater
					}
					$0.formUnion(with: livenessAtAffirmativeBranchEntry)
					$0.formUnion(with: livenessAtNegativeBranchEntry)
				}
				conflicts = with(conflictsInSuccessor) {
					$0.formUnion(with: conflictsInAffirmative)
					$0.formUnion(with: conflictsInNegative)
				}
				
				case .return:
				livenessAtEntry = .nothingUsed
				conflicts = .conflictFree
				
			}
			return (livenessAtEntry, conflicts)
		}
		
		/// Returns a copy of `self` where `successor` is the successor.
		///
		/// This method returns `self` unchanged if `self` is a return effect.
		public func then(_ successor: Self) -> Self {
			switch self {
				
				case .none:
				return successor
				
				case .copy(destination: let destination, source: let source, successor: _):
				return .copy(destination: destination, source: source, successor: successor)
				
				case .compute(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs, successor: _):
				return .compute(destination: destination, lhs: lhs, operation: operation, rhs: rhs, successor: successor)
				
				case .conditional(predicate: let predicate, affirmative: let affirmative, negative: let negative, successor: _):
				return .conditional(predicate: predicate, affirmative: affirmative, negative: negative, successor: successor)
				
				case .return:
				return self
				
			}
		}
		
	}
	
	public typealias BinaryOperator = Lower.BinaryOperator
	
}

public func <- (destination: AL.Location, source: AL.Source) -> AL.Effect {
	.copy(destination: destination, source: source, successor: .return(result: source))
}
