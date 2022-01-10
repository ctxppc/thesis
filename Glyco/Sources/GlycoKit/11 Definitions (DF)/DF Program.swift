// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Definitions
//sourcery: description = A language that introduces definitions with function-wide namespacing.
public enum DF : Language {
	
	/// A program on a DF machine.
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
			let resultValue = Location(rawValue: "result")
			return try .init(
				.do([
					.set(resultValue, to: result.lowered()),
					.return(.location(resultValue))
				]),
				procedures: functions.lowered()
			)
		}
		
	}
	
	// See protocol.
	public typealias Lower = CV
	
	typealias Context = ()
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias DataType = Lower.DataType
	public typealias Label = Lower.Label
	public typealias Location = Lower.Location
	public typealias Parameter = Lower.Parameter
	public typealias Predicate = Lower.Predicate
	public typealias Source = Lower.Source
	
}
