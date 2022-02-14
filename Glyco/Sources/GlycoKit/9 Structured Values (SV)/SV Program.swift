// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Structured Values
//sourcery: description = "A language that introduces structured values (vectors and records)."
public enum SV : Language {
	
	/// A program on an SV machine.
	public struct Program : Codable, GlycoKit.Program {
		
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
			var context = Context()
			return try .init(effect.lowered(in: &context), procedures: procedures.lowered())
		}
		
	}
	
	// See protocol.
	public typealias Lower = ID
	
	public typealias AbstractLocation = Lower.AbstractLocation
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias Frame = Lower.Frame
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Register = Lower.Register
	public typealias Source = Lower.Source
	
}
