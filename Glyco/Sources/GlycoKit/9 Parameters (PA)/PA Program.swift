// Glyco © 2021 Constantino Tsarouhas

/// A language that introduces procedure parameters using the PA calling convention.
public enum PA : Language {
	
	/// A program on a PA machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// Creates a program with given body and procedures.
		public init(body: Statement, procedures: [Procedure]) {
			self.body = body
			self.procedures = procedures
		}
		
		/// The program's body.
		public var body: Statement
		
		/// The program's procedures.
		public var procedures: [Procedure]
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = Context(procedures: procedures)
			return try .init(body: body.lowered(in: &context), procedures: procedures.lowered(in: &context))
		}
		
	}
	
	// See protocol.
	public typealias Lower = EX
	
	public typealias DataType = Lower.DataType
	public typealias Expression = Lower.Expression
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Predicate = Lower.Predicate
	
}
