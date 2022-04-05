// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = Objects
//sourcery: description = "A language that introduces objects, i.e., encapsulated values with methods."
public enum OB : Language {
	
	/// A program on an OB machine.
	public struct Program : Codable, GlycoKit.Program {
		
		public init(_ result: Result, functions: [Function], types: [TypeDefinition]) {
			self.result = result
			self.functions = functions
			self.types = types
		}
		
		/// The program's result.
		public var result: Result
		
		/// The program's functions.
		public var functions: [Function]
		
		/// The program's type definitions.
		public var types: [TypeDefinition]
		
		// See protocol.
		public func optimise(configuration: CompilationConfiguration) -> Bool { false }
		
		// See protocol.
		public func validate(configuration: CompilationConfiguration) {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			
			var context = Context(selfName: nil, types: types)
			
			var globals = [Lower.GlobalDeclaration]()
			var functions = try self.functions.lowered(in: &context)
			for type in types {
				
				guard case .object(let typeName, let objectType) = type else { continue }
				context.objectTypeName = typeName
				
				functions.append(try objectType.initialiser.lowered(in: &context))
				functions.append(contentsOf: try objectType.methods.lowered(in: &context))
				
			}
			context.objectTypeName = nil
			
			return try .init(result.lowered(in: &context), functions: functions, types: types.lowered(in: &context), globals: globals)
			
		}
		
	}
	
	// See protocol.
	public typealias Lower = NT
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias Field = Lower.Field
	public typealias Label = Lower.Label
	public typealias Parameter = Lower.Parameter
	public typealias RecordType = Lower.RecordType
	public typealias Symbol = Lower.Symbol
	public typealias TypeName = Lower.TypeName
	
}
