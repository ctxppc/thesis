// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Abstract Locations
//sourcery: description = "A language that introduces abstract locations, i.e., locations whose physical locations are not specified by the programmer."
public enum AL : Language {
	
	/// A program on an AL machine.
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
		public func optimise(configuration: CompilationConfiguration) -> Bool { false }
		
		// See protocol.
		public func validate(configuration: CompilationConfiguration) {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var analysis = Lower.Analysis()
			return try .init(
				locals:		locals,
				in:			effect.lowered().updated(using: { $0 }, analysis: &analysis, configuration: configuration),
				procedures:	procedures.map { try $0.lowered(configuration: configuration) }
			)
		}
		
	}
	
	// See protocol.
	public typealias Lower = ALA
	
	typealias Context = ()
	
	public typealias AbstractLocation = Lower.AbstractLocation
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Declarations = Lower.Declarations
	public typealias Frame = Lower.Frame
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Register = Lower.Register
	public typealias Source = Lower.Source
	
}
