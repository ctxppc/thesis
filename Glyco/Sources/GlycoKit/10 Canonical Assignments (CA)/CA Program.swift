// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Canonical Assignments
//sourcery: description = A language that groups all effects that write to a location under one canonical assignment effect.
public enum CA : Language {
	
	/// A program on a CA machine.
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
	public typealias Lower = CC
	
	typealias Context = ()
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias ValueType = Lower.ValueType
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Parameter = Lower.Parameter
	public typealias Source = Lower.Source
	
}
