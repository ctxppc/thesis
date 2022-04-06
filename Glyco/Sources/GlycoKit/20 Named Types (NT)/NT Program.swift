// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

//sourcery: longname = Named Types
//sourcery: description = "A language that introduces named types in a structural type system."
public enum NT : Language {
	
	/// A program on an NT machine.
	public struct Program : Codable, GlycoKit.Program {
		
		/// Creates a program.
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
	public typealias Lower = Λ
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias Label = Lower.Label
	public typealias Symbol = Lower.Symbol
	
}
