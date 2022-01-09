// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Calling Convention
//sourcery: description = A language that introduces parameter passing and enforces the low-level Glyco calling convention.
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
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = Context(procedures: procedures, configuration: configuration)
			return try .init(effect.lowered(in: &context), procedures: procedures.lowered(in: &context))
		}
		
	}
	
	// See protocol.
	public typealias Lower = AL
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Label = Lower.Label
	public typealias Location = Lower.AbstractLocation
	
}
