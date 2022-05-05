// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

//sourcery: longname = Named Types
//sourcery: description = "A language that introduces named alias and nominal types."
public enum NT : Language {
	
	/// A program on an NT machine.
	public struct Program : GlycoKit.Program {
		
		/// Creates a program.
		public init(_ result: Result, functions: [Function]) {
			self.result = result
			self.functions = functions
		}
		
		/// The program's result.
		///
		/// The result must be a `s32`. If the result is of a nominal type, it is implicitly casted to `s32`.
		public var result: Result
		
		/// The program's functions.
		public var functions: [Function]
		
		// See protocol.
		public func optimise(configuration: CompilationConfiguration) -> Bool { false }
		
		// See protocol.
		public func validate(configuration: CompilationConfiguration) throws {
			
			let context = TypingContext(functions: functions)
			
			let actualResultType = try result.assignedType(in: context).structural()
			guard actualResultType == .s32 else { throw TypingError.resultTypeMismatch(result, expected: .s32, actual: actualResultType) }
			
			for function in functions {
				
				var bodyContext = context
				bodyContext.assignedTypesBySymbol = .init(uniqueKeysWithValues: try function.parameters.map { parameter in
					if parameter.sealed {
						guard case .cap(let capType) = parameter.type else { throw TypingError.noncapabilitySealedParameter(parameter) }
						return (parameter.name, .init(from: .cap(capType.sealed(false)), in: context))
					} else {
						return (parameter.name, .init(from: parameter.type, in: context))
					}
				})
				
				let normalisedDeclaredResultType = try function.resultType.normalised(in: context)
				let normalisedActualResultType = try result.assignedType(in: bodyContext).normalised()
				
				let typesMatchDirectly = normalisedActualResultType == normalisedDeclaredResultType
				let typesMatchAfterConversion = { try normalisedActualResultType == normalisedDeclaredResultType.structural(in: context) }
				
				guard try typesMatchDirectly || typesMatchAfterConversion() else {
					throw TypingError.resultTypeMismatch(function.result, expected: normalisedDeclaredResultType, actual: normalisedActualResultType)
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
