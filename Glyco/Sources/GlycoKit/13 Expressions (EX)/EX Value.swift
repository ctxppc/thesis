// Glyco © 2021–2022 Constantino Tsarouhas

extension EX {
	
	public enum Value : Codable, Equatable, SimplyLowerable {
		
		/// The operand is a given value.
		case constant(Int)
		
		/// The operand is to be retrieved from a given location.
		case symbol(Symbol)
		
		/// A value that evaluates to *x* *op* *y* where *x* and *y* are given sources and *op* is given operator.
		indirect case binary(Value, BinaryOperator, Value)
		
		/// A value that evaluates to the value of `then` if the predicate holds, or to the value of `else` otherwise.
		indirect case `if`(Predicate, then: Value, else: Value)
		
		/// A value that evaluates to a function evaluated with given arguments.
		case evaluate(Label, [Value])
		
		/// A value that evaluates to given value after associating zero or more values with a name.
		indirect case `let`([Definition], in: Value)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Value {
			switch self {
				
				case .constant(let value):
				return .source(.constant(value))
					
				case .symbol(let symbol):
				return .source(.symbol(symbol))
				
				case .binary(let lhs, let op, let rhs):
				let l = Lower.Symbol(rawValue: "lhs")	// TODO: Risk of shadowing?
				let r = Lower.Symbol(rawValue: "rhs")
				return try .let([
					.init(l, lhs.lowered(in: &context)),
					.init(r, rhs.lowered(in: &context))
				], in: .binary(.symbol(l), op, .symbol(r)))
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .evaluate(let name, let arguments):
				let namesAndDefinitions = try arguments.enumerated().map { (n, argument) -> (Lower.Symbol, Lower.Definition) in
					let name = Lower.Symbol(rawValue: "arg\(n)")
					return (name, .init(name, try argument.lowered(in: &context)))
				}
				return .let(namesAndDefinitions.map(\.1), in: .evaluate(name, namesAndDefinitions.map { .symbol($0.0) }))
				
				case .let(let definitions, in: let body):
				return try .let(definitions.lowered(in: &context), in: body.lowered(in: &context))
				
			}
		}
		
	}
	
}
