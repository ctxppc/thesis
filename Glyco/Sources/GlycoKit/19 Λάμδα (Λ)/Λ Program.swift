// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Lambdas
//sourcery: description = "A language that introduces anonymous functions and function values."
public enum Λ : Language {
	
	/// A program on a Λ machine.
	public struct Program : GlycoKit.Program {
		
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
			var context = Λ.Context()
			return try .init(
				result.lowered(in: &context),
				functions: functions.lowered(in: &context) + context.anonymousFunctions
			)
		}
		
	}
	
	// See protocol.
	public typealias Lower = EX
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias CapabilityType = Lower.CapabilityType
	public typealias Field = Lower.Field
	public typealias Label = Lower.Label
	public typealias Parameter = Lower.Parameter
	public typealias RecordType = Lower.RecordType
	public typealias Symbol = Lower.Symbol
	public typealias ValueType = Lower.ValueType
	
}
