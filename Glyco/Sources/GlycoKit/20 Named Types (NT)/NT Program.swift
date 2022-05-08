// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

//sourcery: longname = Named Types
//sourcery: description = "A language that introduces named alias and nominal types."
public enum NT : Language {
	
	/// A program on an NT machine.
	public struct Program : GlycoKit.Program {
		
		/// Creates a program with given result.
		public init(_ result: Result) {
			self.result = result
		}
		
		/// The program's result.
		///
		/// The result must be a `s32`. If the result is of a nominal type, it is implicitly casted to `s32`.
		public var result: Result
		
		// See protocol.
		public func optimise(configuration: CompilationConfiguration) -> Bool { false }
		
		// See protocol.
		public func validate(configuration: CompilationConfiguration) throws {
			let context = TypingContext()
			let actualResultType = try result.assignedType(in: context).structural()
			guard actualResultType == .s32 else { throw TypingError.resultTypeMismatch(result, expected: .s32, actual: actualResultType) }
		}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = LoweringContext()
			return try .init(result.lowered(in: &context))
		}
		
	}
	
	// See protocol.
	public typealias Lower = Λ
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias BranchRelation = Lower.BranchRelation
	public typealias Label = Lower.Label
	public typealias Symbol = Lower.Symbol
	
}
