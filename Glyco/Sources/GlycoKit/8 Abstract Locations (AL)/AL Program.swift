// Glyco © 2021 Constantino Tsarouhas

/// A language that introduces abstract locations, i.e., locations whose physical locations are not specified by the programmer.
public enum AL : Language {
	
	/// A program on an AL machine.
	public enum Program : Codable, GlycoKit.Program {
		
		/// A program with given effect and procedures.
		case program(Effect, procedures: [Procedure])
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			switch self {
				case .program(let effect, let procedures):
				let (_, conflicts) = effect.livenessAndConflictsAtEntry(livenessAtExit: .nothingUsed, conflictsAtExit: .conflictFree)
				var context = Context(assignments: .init(conflicts: conflicts))
				return try .init(effect: effect.lowered(in: &context), procedures: procedures.lowered())
			}
		}
		
	}
	
	// See protocol.
	public typealias Lower = PA
	
	public typealias DataType = Lower.DataType
	public typealias Label = Lower.Label
	
}
