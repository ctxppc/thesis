// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Calling Convention
//sourcery: description = A language that introduces parameters & result values in procedures via the low-level Glyco calling convention.
public enum CC : Language {
	
	/// A program on a CC machine.
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
		public func optimise(configuration: CompilationConfiguration) -> Bool { false }
		
		// See protocol.
		public func validate(configuration: CompilationConfiguration) {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = Context(procedures: procedures, configuration: configuration)
			return try .init(try .do {
				
				// Prepare new scope.
				Lower.Effect.pushScope
				
				// Bind return capability.
				Lower.Effect.set(.abstract(context.returnLocation), to: .register(.ra, .cap(.code)))
				
				// Execute main effect.
				try effect.lowered(in: &context)
				
			}, procedures: procedures.lowered(in: &context))
		}
		
	}
	
	// See protocol.
	public typealias Lower = SV
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias CapabilityType = Lower.CapabilityType
	public typealias Field = Lower.Field
	public typealias Label = Lower.Label
	public typealias Location = Lower.AbstractLocation
	public typealias RecordType = Lower.RecordType
	public typealias ValueType = Lower.ValueType
	
}
