// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

//sourcery: longname = Named Types
//sourcery: description = "A language that introduces named structural and nominal types."
public enum NT : Language {
	
	/// A program on an NT machine.
	public struct Program : GlycoKit.Program {
		
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
		public func validate(configuration: CompilationConfiguration) throws {
			
			let context = TypingContext(functions: functions)
			
			let actualResultType = try result.normalisedValueType(in: context)
			guard actualResultType == .s32 else { throw TypingError.resultTypeMismatch(result, expected: .s32, actual: actualResultType) }
			
			for function in functions {
				let actualResultType = try function.result.normalisedValueType(in: context)
				guard actualResultType == function.resultType else {
					throw TypingError.resultTypeMismatch(function.result, expected: function.resultType, actual: actualResultType)
				}
			}
			
		}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = LoweringContext()
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
