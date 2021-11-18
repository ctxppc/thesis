// Glyco © 2021 Constantino Tsarouhas

/// A language that introduces abstract locations, i.e., locations whose physical locations are not specified by the programmer.
public enum AL : Language {
	
	/// A program on an AL machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// Creates a program with given effect and procedures.
		public init(effect: Effect, procedures: [Procedure]) {
			self.effect = effect
			self.procedures = procedures
		}
		
		/// The program's effect.
		public var effect: Effect
		
		/// The program's procedures.
		public var procedures: [Procedure]
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			let (_, conflicts) = effect.livenessAndConflictsAtEntry(livenessAtExit: .nothingUsed, conflictsAtExit: .conflictFree)
			var context = Context(assignments: .init(conflicts: conflicts))
			return try .init(effect: effect.lowered(in: &context), procedures: procedures.lowered())
		}
		
	}
	
	// See protocol.
	public typealias Lower = CD
	
	public typealias Label = Lower.Label
	
}
