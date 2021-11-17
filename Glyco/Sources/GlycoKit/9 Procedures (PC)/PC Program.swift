// Glyco © 2021 Constantino Tsarouhas

/// A language that introduces procedures.
public enum PC : Language {
	
	/// A program on an PC machine.
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
		public func lowered(configuration: CompilationConfiguration) -> Lower.Program {
			TODO.unimplemented
		}
		
	}
	
	// See protocol.
	public typealias Lower = EX
	
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Predicate = Lower.Predicate
	public typealias Statement = Lower.Statement
	
}
