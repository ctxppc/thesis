// Glyco © 2021–2022 Constantino Tsarouhas

extension NT {
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
		func lowered(in context: inout LoweringContext) throws -> Lower.Result {
			switch self {
				
				case .value(let value):
				return .value(try value.lowered(in: &context))
				
				case .evaluate(let function, let arguments):
				return try .evaluate(function.lowered(in: &context), arguments.lowered(in: &context))
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .let(let definitions, in: let result):
				return try .let(definitions.lowered(in: &context), in: result.lowered(in: &context))
				
				case .do(let effects, then: let result):
				return try .do(effects.lowered(in: &context), then: result.lowered(in: &context))
				
			}
		}
		
		/// Determines the normalised value type of `self`.
		func normalisedValueType(in context: TypingContext) throws -> ValueType {
			switch self {
				
				case .value(let value):
				return try value.assignedType(in: context).normalised
				
				case .evaluate(let function, let arguments):
				guard case .cap(.function(takes: let parameters, returns: let resultType)) = try function.assignedType(in: context).normalised else {
					throw TypingError.nonfunctionValue(function)
				}
				for (parameter, argument) in zip(parameters, arguments) {
					let argumentType = try argument.assignedType(in: context).normalised
					if argumentType != parameter.type {	// parameter is already normalised in a normalised function type
						throw TypingError.argumentTypeMismatch(argument, argumentType, parameter)
					}
				}
				return resultType	// result type is already normalised in a normalised function type
				
				case .if(_, then: let affirmative, else: let negative):
				// TODO: Type-check predicate?
				let affirmativeType = try affirmative.normalisedValueType(in: context)
				let negativeType = try negative.normalisedValueType(in: context)
				guard affirmativeType == negativeType else { throw TypingError.branchTypeMismatch(affirmative: affirmativeType, negative: negativeType) }
				return affirmativeType
				
				case .let(let definitions, in: let body):
				var context = context
				for definition in definitions {
					context.assignedTypesBySymbol[definition.name] = try definition.value.assignedType(in: context)
				}
				return try body.normalisedValueType(in: context)
				
				case .do(_, then: let value):
				// TODO: Type-check effects?
				return try value.normalisedValueType(in: context)
				
			}
		}
		
	}
}
