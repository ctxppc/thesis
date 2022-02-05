// Glyco © 2021–2022 Constantino Tsarouhas

extension DF {
	
	public enum Result : Codable, Equatable, SimplyLowerable {
		
		/// A result that evaluates to given value.
		case value(Value)
		
		/// A result that evaluates to the value of `then` if the predicate holds, or to the value of `else` otherwise.
		indirect case `if`(Predicate, then: Result, else: Result)
		
		/// A result that evaluates to a function evaluated with given arguments.
		case evaluate(Label, [Source])
		
		/// A result provided by given result after associating zero or more values with a name.
		indirect case `let`([Definition], in: Result)
		
		/// A result provided by given result after performing given effects.
		indirect case `do`([Effect], then: Result)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .value(let value):
				let result = Lower.Location(rawValue: "result")
				return .do([
					.set(result, to: try value.lowered(in: &context)),
					.return(.location(result))
				])
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .evaluate(let name, let arguments):
				return .call(name, arguments)
				
				case .let(let definitions, in: let result):
				return try .do(definitions.lowered(in: &context) + [result.lowered(in: &context)])
				
				case .do(let effects, then: let result):
				return try .do(effects.lowered(in: &context) + [result.lowered(in: &context)])
				
			}
		}
		
	}
	
}
