// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Objects
//sourcery: description = "A language that introduces objects, i.e., encapsulated values with methods."
public enum OB : Language {
	
	/// A program on an OB machine.
	public struct Program : Codable, GlycoKit.Program {
		
		public init(_ result: Result, functions: [Function], typeDefinitions: [TypeDefinition]) {
			self.result = result
			self.functions = functions
			self.typeDefinitions = typeDefinitions
		}
		
		/// The program's result.
		public var result: Result
		
		/// The program's functions.
		public var functions: [Function]
		
		/// The program's type definitions.
		public var typeDefinitions: [TypeDefinition]
		
		// See protocol.
		public func optimise(configuration: CompilationConfiguration) -> Bool { false }
		
		// See protocol.
		public func validate(configuration: CompilationConfiguration) {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = Context(inMethod: false)
			return try .init(
				result.lowered(in: &context),
				functions: functions.lowered(),
				typeDefinitions: typeDefinitions.lowered()
			)
		}
		
	}
	
	// See protocol.
	public typealias Lower = NT
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias Label = Lower.Label
	public typealias Parameter = Lower.Parameter
	public typealias RecordType = Lower.RecordType
	public typealias Symbol = Lower.Symbol
	
}
