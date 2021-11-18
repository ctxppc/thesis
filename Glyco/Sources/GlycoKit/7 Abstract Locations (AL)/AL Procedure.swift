// Glyco © 2021 Constantino Tsarouhas

extension AL {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, SimplyLowerable {
		
		/// The name with which the procedure can be invoked.
		var name: Label
		
		/// The procedure's effect when invoked.
		var effect: Effect
		
		// See protocol.
		func lowered(in context: inout ()) throws -> Lower.Procedure {	// does not support AL.Context
			let (_, conflicts) = effect.livenessAndConflictsAtEntry(livenessAtExit: .nothingUsed, conflictsAtExit: .conflictFree)
			var context = AL.Context(assignments: .init(conflicts: conflicts))
			return .init(name: name, effect: try effect.lowered(in: &context))
		}
		
	}
	
}
