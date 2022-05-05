// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Runtime
//sourcery: description = "A language that introduces a runtime system and runtime routines."
public enum RT : Language {
	
	/// An RT program.
	public struct Program : GlycoKit.Program {
		
		/// Creates a program with given statements.
		public init(_ statements: [Statement] = []) {
			self.statements = statements
		}
		
		//sourcery: isInternalForm
		public init(@ArrayBuilder<Statement> _ statements: () throws -> [Statement]) rethrows {
			self.init(try statements())
		}
		
		/// The program's effects.
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
	public typealias Lower = CE
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Label = Lower.Label
	public typealias Permission = Lower.Permission
	public typealias Register = Lower.Register
	public typealias Source = Lower.Source
	public typealias Target = Lower.Target
	
}
