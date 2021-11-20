// Glyco © 2021 Constantino Tsarouhas

/// A language that introduces structural value expressions, thereby abstracting over simple computation effects.
public enum EX : Language {
	
	/// A program on an EX machine.
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
			var context = Context()
			return try .init(effect: body.lowered(in: &context), procedures: procedures.lowered(in: &context))
		}
		
	}
	
	// See protocol.
	public typealias Lower = AL
	
	public typealias DataType = Lower.DataType
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Predicate = Lower.Predicate
	
}
