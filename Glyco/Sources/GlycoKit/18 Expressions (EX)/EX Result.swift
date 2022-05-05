// Glyco © 2021–2022 Constantino Tsarouhas

extension EX {
	
	public enum Result : SimplyLowerable, Element {
		
		/// A result that evaluates to given value.
		case value(Value)
		
		/// A result that evaluates to given function evaluated with given arguments.
		indirect case evaluate(Value, [Value])
		
		/// A result that evaluates to the value of `then` if the predicate holds, or to the value of `else` otherwise.
		indirect case `if`(Predicate, then: Result, else: Result)
		
		/// A result provided by given result after associating zero or more values with a name.
		indirect case `let`([Definition], in: Result)
		
		/// A result provided by given result after performing given effects.
		indirect case `do`([Effect], then: Result)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Result {
			switch self {
				
				case .value(let value):
				return try .value(value.lowered(in: &context))
				
				case .evaluate(.function(let name), let arguments):
				let definitions = try arguments.map {
					Lower.Definition(context.symbols.uniqueName(from: "arg"), try $0.lowered(in: &context))
				}
				return .let(definitions, in: .evaluate(.function(name), definitions.map { .named($0.name) }))
				
				case .evaluate(let function, let arguments):
				let f = context.symbols.uniqueName(from: "f")
				let definitions = try arguments.map {
					Lower.Definition(context.symbols.uniqueName(from: "arg"), try $0.lowered(in: &context))
				}
				return .let(
					definitions + [.init(f, try function.lowered(in: &context))],
					in: .evaluate(.named(f), definitions.map { .named($0.name) })
				)
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .let(let definitions, in: let result):
				return try .let(definitions.lowered(in: &context), in: result.lowered(in: &context))
				
				case .do(let effects, then: let result):
				return try .do(effects.lowered(in: &context), then: result.lowered(in: &context))
				
			}
		}
		
	}
	
}
