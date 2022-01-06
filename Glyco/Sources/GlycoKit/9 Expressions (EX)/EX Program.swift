// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Expressions
//sourcery: description = "A language that introduces structural value expressions, thereby abstracting over simple computation effects."
public enum EX : Language {
	
	/// A program on an EX machine.
	public struct Program : Codable, GlycoKit.Program {
		
		public init(_ body: Statement, procedures: [Procedure]) {
			self.body = body
			self.procedures = procedures
		}
		
		/// The program's main body.
		public var body: Statement
		
		/// The program's procedures.
		public var procedures: [Procedure]
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = Context()
			return try .init(body.lowered(in: &context), procedures: procedures.lowered(in: &context))
		}
		
	}
	
	// See protocol.
	public typealias Lower = PA
	
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Parameter = Lower.Parameter
	
}
