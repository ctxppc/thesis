// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

//sourcery: longname = Named Types
//sourcery: description = "A language that introduces named types in a structural type system."
public enum NT : Language {
	
	/// A program on an NT machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// Creates a program.
		public init(_ result: Result, functions: [Function], types: [TypeDefinition], globals: [GlobalDeclaration]) {
			self.result = result
			self.functions = functions
			self.types = types
			self.globals = globals
		}
		
		/// The program's result.
		public var result: Result
		
		/// The program's functions.
		public var functions: [Function]
		
		/// The program's types.
		public var types: [TypeDefinition]
		
		/// The program's globals.
		public var globals: [GlobalDeclaration]
		
		// See protocol.
		public func optimise(configuration: CompilationConfiguration) -> Bool { false }
		
		// See protocol.
		public func validate(configuration: CompilationConfiguration) {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			
			var valueTypesByName = [TypeName : ValueType]()
			for definition in types {
				let previous = valueTypesByName.updateValue(definition.type, forKey: definition.name)
				if let previous = previous {
					throw LoweringError.duplicateTypeDefinitions(definition.name, previous, definition.type)
				}
			}
			
			// TODO: Lower globals
			
			var context = Context(valueTypesByName: valueTypesByName)
			return try .init(result.lowered(in: &context), functions: functions.lowered(in: &context))
			
		}
		
		enum LoweringError : LocalizedError {
			
			/// An error indicating that given name is associated to two given value types.
			case duplicateTypeDefinitions(TypeName, ValueType, ValueType)
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					case .duplicateTypeDefinitions(let name, let first, let second):
					return "“\(name)” is defined as “\(first)” and as “\(second)”"
				}
			}
			
		}
		
	}
	
	// See protocol.
	public typealias Lower = Λ
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias Field = Lower.Field
	public typealias Label = Lower.Label
	public typealias RecordType = Lower.RecordType
	public typealias Symbol = Lower.Symbol
	
}
