// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = "Abstract Locations, Analysed"
//sourcery: description = "A language that introduces abstract locations, annotated with liveness and conflict information."
public enum ALA : Language {
	
	/// A program on an ALA machine.
	public struct Program : Codable, GlycoKit.Program {
		
		public init(locals: Declarations, in effect: Effect, procedures: [Procedure]) {
			self.locals = locals
			self.effect = effect
			self.procedures = procedures
		}
		
		/// The declared locations.
		public var locals: Declarations
		
		/// The program's effect.
		public var effect: Effect
		
		/// The program's procedures.
		public var procedures: [Procedure]
		
		// See protocol.
		public mutating func optimise(configuration: CompilationConfiguration) throws -> Bool {
			
			var optimised = false
			var analysis = effect.analysisAtEntry
			while let (removedLocation, retainedLocation) = effect.safelyCoalescableLocations(analysisAtScopeEntry: analysis) {
				analysis = .init()
				effect = try effect.coalescing(
					removedLocation,
					into:			retainedLocation,
					declarations:	locals,
					analysis:		&analysis,
					configuration:	configuration
				)
				locals.remove(.abstract(removedLocation))	// must be done after coalescing — cf. Effect.coalescing(…)
				optimised = true
			}
			
			for index in procedures.indices {
				let procedureOptimised = try procedures[index].optimise(configuration: configuration)
				optimised = optimised || procedureOptimised
			}
			
			return optimised
			
		}
		
		// See protocol.
		public func validate(configuration: CompilationConfiguration) {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = Context(
				declarations:	locals,
				assignments:	try .init(declarations: locals, analysisAtScopeEntry: effect.analysisAtEntry, configuration: configuration),
				configuration:	configuration
			)
			return try .init(
				effect.lowered(in: &context),
				procedures: procedures.map { try $0.lowered(configuration: configuration) }
			)
		}
		
	}
	
	// See protocol.
	public typealias Lower = CD
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Frame = Lower.Frame
	public typealias Label = Lower.Label
	public typealias Register = Lower.Register
	
}
