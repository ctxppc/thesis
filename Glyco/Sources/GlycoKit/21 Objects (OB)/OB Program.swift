// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Objects
//sourcery: description = "A language that introduces objects, i.e., encapsulated values with methods."
public enum OB : Language {
	
	/// A program on an OB machine.
	public struct Program : Codable, GlycoKit.Program {
		
		public init(_ result: Result, functions: [Function]) {
			self.result = result
			self.functions = functions
		}
		
		/// The program's result.
		public var result: Result
		
		/// The program's functions.
		public var functions: [Function]
		
		// See protocol.
		public func optimise(configuration: CompilationConfiguration) -> Bool { false }
		
		// See protocol.
		public func validate(configuration: CompilationConfiguration) {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = Context()
			return try .init(result.lowered(in: &context), functions: functions.lowered(in: &context))
		}
		
	}
	
	// See protocol.
	public typealias Lower = NT
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias Label = Lower.Label
	public typealias Symbol = Lower.Symbol
	public typealias TypeName = Lower.TypeName
	
}
