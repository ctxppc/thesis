// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Closures
//sourcery: description = "A language that introduces closures, i.e., anononymous functions with an environment."
public enum CL : Language {
	
	/// A program on a CL machine.
	public struct Program : GlycoKit.Program {
		
		/// Creates a program with given result.
		public init(_ result: Result) {
			self.result = result
		}
		
		/// The program's result.
		public var result: Result
		
		// See protocol.
		public func optimise(configuration: CompilationConfiguration) -> Bool { false }
		
		// See protocol.
		public func validate(configuration: CompilationConfiguration) {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = Context()
			return try .init(result.lowered(in: &context))
		}
		
	}
	
	// See protocol.
	public typealias Lower = OB
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias Field = Lower.Field
	public typealias Label = Lower.Label
	public typealias Parameter = Lower.Parameter
	public typealias RecordType = Lower.RecordType
	public typealias Symbol = Lower.Symbol
	public typealias TypeName = Lower.TypeName
	public typealias TypeDefinition = Lower.TypeDefinition
	public typealias ValueType = Lower.ValueType
	
}
