// Glyco © 2021–2022 Constantino Tsarouhas

extension LS {
	
	public enum Result : Codable, Equatable, SimplyLowerable {
		
		/// A result that evaluates to given value.
		case value(Value)
		
		/// A result that evaluates to the value of `then` if the predicate holds, or to the value of `else` otherwise.
		indirect case `if`(Predicate, then: Result, else: Result)
		
		/// A result that evaluates to a function evaluated with given arguments.
		case evaluate(Label, [Source])
		
		/// A result provided by given result after associating zero or more values with a name.
		indirect case `let`([Definition], in: Result)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Result {
			switch self {
				
				case .value(let value):
				return try .value(value.lowered(in: &context))
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .evaluate(let name, let arguments):
				return .evaluate(name, try arguments.lowered(in: &context))
				
				case .let(let definitions, in: let result):
				return try .let(definitions.lowered(in: &context), in: result.lowered(in: &context))
				
			}
		}
		
	}
	
}
