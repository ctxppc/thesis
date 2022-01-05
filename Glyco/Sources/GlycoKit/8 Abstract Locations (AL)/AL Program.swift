// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Abstract Locations
/// A language that introduces abstract locations, i.e., locations whose physical locations are not specified by the programmer.
public enum AL : Language {
	
	/// A program on an AL machine.
	public struct Program : Codable, GlycoKit.Program {
		
		public init(_ effect: Effect, procedures: [Procedure]) {
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
			var globalContext = GlobalContext(configuration: configuration)
			var mainLocalContext = LocalContext(
				assignments: .init(
					parameters:			[],
					conflicts:			conflicts,
					argumentRegisters:	configuration.argumentRegisters
				)
			)
			return try .init(effect.lowered(in: &mainLocalContext), procedures: procedures.lowered(in: &globalContext))
		}
		
	}
	
	// See protocol.
	public typealias Lower = PA
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Label = Lower.Label
	
}
