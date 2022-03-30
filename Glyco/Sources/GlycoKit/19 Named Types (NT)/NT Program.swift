// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

//sourcery: longname = Named Types
//sourcery: description = "A language that introduces named types in a structural type system."
public enum NT : Language {
	
	/// A program on an NT machine.
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
			
			var valueTypesByName = [Symbol : ValueType]()
			for definition in typeDefinitions {
				let previous = valueTypesByName.updateValue(definition.type, forKey: definition.name)
				if let previous = previous {
					throw LoweringError.duplicateTypeDefinitions(definition.name, previous, definition.type)
				}
			}
			
			var context = Context(valueTypesByName: valueTypesByName)
			return try .init(result.lowered(in: &context), functions: functions.lowered(in: &context))
			
		}
		
		enum LoweringError : LocalizedError {
			
			/// An error indicating that given name is associated to two given value types.
			case duplicateTypeDefinitions(Symbol, ValueType, ValueType)
			
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
	public typealias Lower = EX
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias Label = Lower.Label
	public typealias Parameter = Lower.Parameter
	public typealias RecordType = Lower.RecordType
	public typealias Symbol = Lower.Symbol
	
}
