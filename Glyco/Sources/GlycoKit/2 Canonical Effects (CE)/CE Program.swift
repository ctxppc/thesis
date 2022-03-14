// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Canonical Effects
//sourcery: description = "A language grouping related instructions under a single effect."
public enum CE : Language {
	
	/// A CE program.
	public struct Program : Codable, GlycoKit.Program {
		
		/// Creates a program with given statements.
		public init(_ statements: [Statement] = []) {
			self.statements = statements
		}
		
		//sourcery: isInternalForm
		public init(@ArrayBuilder<Statement> _ statements: () throws -> [Statement]) rethrows {
			self.init(try statements())
		}
		
		/// The program's statements.
		public var statements: [Statement] = []
		
		// See protocol.
		public func optimise(configuration: CompilationConfiguration) -> Bool { false }
		
		// See protocol.
		public func validate(configuration: CompilationConfiguration) {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			.init(try statements.lowered())
		}
		
	}
	
	// See protocol.
	public typealias Lower = RV
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias Label = Lower.Label
	public typealias Register = Lower.Register
	
}
