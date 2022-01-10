// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Lexical Scopes
//sourcery: description = A language that introduces lexical scopes of definitions, thereby removing name clashes.
public enum LS : Language {
	
	/// A program on a LS machine.
	public struct Program : Codable, GlycoKit.Program {
		
		public init(_ result: Value, functions: [Function]) {
			self.result = result
			self.functions = functions
		}
		
		/// The program's result.
		public var result: Value
		
		/// The program's functions.
		public var functions: [Function]
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = Context()
			return try .init(result.lowered(in: &context), functions: functions.lowered())
		}
		
	}
	
	// See protocol.
	public typealias Lower = DF
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Label = Lower.Label
	
}
