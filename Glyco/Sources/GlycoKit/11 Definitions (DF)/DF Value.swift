// Glyco © 2021–2022 Constantino Tsarouhas

extension DF {
	
	public enum Value : Codable, Equatable, SimplyLowerable {
		
		/// A value that evaluates to the value of given source.
		case source(Source)
		
		/// A value that evaluates to *x* *op* *y* where *x* and *y* are given sources and *op* is given operator.
		case binary(Source, BinaryOperator, Source)
		
		/// A value that evaluates to the value of `then` if the predicate holds, or to the value of `else` otherwise.
		indirect case `if`(Predicate, then: Value, else: Value)
		
		/// A value that evaluates to a function evaluated with given arguments.
		case evaluate(Label, [Source])
		
		/// A value that evaluates to given value after associating zero or more values with a name.
		indirect case `let`([Definition], in: Value)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Value {
			switch self {
				
				case .source(let source):
				return .source(source)
				
				case .binary(let lhs, let op, let rhs):
				return .binary(lhs, op, rhs)
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .evaluate(let name, let arguments):
				return .call(name, arguments)
				
				case .let(let definitions, in: let body):
				return try .do(definitions.lowered(in: &context), then: body.lowered(in: &context))
				
			}
		}
		
	}
	
}
