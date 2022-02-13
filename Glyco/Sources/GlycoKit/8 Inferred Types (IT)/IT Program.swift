// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Inferred Types
//sourcery: description = "A language that introduces data type inference."
public enum IT : Language {
	
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
			var context = Context()
			let effect = try effect.lowered(in: &context)	// first get declarations into context
			return try .init(locals: context.declarations, in: effect, procedures: procedures.lowered())
		}
		
	}
	
	// See protocol.
	public typealias Lower = AL
	
	public typealias AbstractLocation = Lower.AbstractLocation
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias ValueType = Lower.ValueType
	public typealias Frame = Lower.Frame
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Register = Lower.Register
	public typealias Source = Lower.Source
	public typealias Declarations = Lower.Declarations
	
}
