// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Definitions
//sourcery: description = A language that introduces definitions with function-wide namespacing.
public enum DF : Language {
	
	/// A program on a DF machine.
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
		public func optimise() -> Bool { false }
		
		// See protocol.
		public func validate() {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = Context()
			return try .init(result.lowered(in: &context), procedures: functions.lowered(in: &context))
		}
		
	}
	
	// See protocol.
	public typealias Lower = CV
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias ValueType = Lower.ValueType
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Parameter = Lower.Parameter
	public typealias Source = Lower.Source
	
}
