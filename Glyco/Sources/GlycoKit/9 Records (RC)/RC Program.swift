// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Records
//sourcery: description = "A language that introduces records."
public enum RC : Language {
	
	/// A program on an RC machine.
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
			try .init(effect.lowered(), procedures: procedures.lowered())
		}
		
	}
	
	// See protocol.
	public typealias Lower = IT
	
	typealias Context = ()
	
	public typealias AbstractLocation = Lower.AbstractLocation
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias Frame = Lower.Frame
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Register = Lower.Register
	public typealias Source = Lower.Source
	public typealias Declarations = Lower.Declarations
	
}