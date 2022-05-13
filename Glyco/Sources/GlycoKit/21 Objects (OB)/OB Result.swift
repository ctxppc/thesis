// Glyco © 2021–2022 Constantino Tsarouhas

extension OB {
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
				return .value(try value.lowered(in: &context))
				
				case .evaluate(.message(let receiver, let methodName), let arguments):	// Optimisation: avoid allocating a pair by inlining the message.
				let receiverType = try receiver.type(in: context)
				guard case .cap(.object(let typeName)) = receiverType else { throw TypingError.messagingNonobject(receiver, actualType: receiverType) }
				guard let typeDefinition = context.type(named: typeName) else { throw TypingError.unknownObjectType(typeName) }
				guard case .object(let objectType) = typeDefinition else { throw TypingError.notAnObjectTypeDefinition(typeName, actual: typeDefinition) }
				guard let method = objectType.methods[methodName] else { throw TypingError.undefinedMethod(receiver: receiver, objectType: objectType, methodName: methodName) }
				return .evaluate(.named(method.symbol(typeName: typeName)), try [receiver.lowered(in: &context)] + arguments.lowered(in: &context))
				
				case .evaluate(let target, let arguments):
				if case .cap(.message) = try target.type(in: context) {
					return try .evaluate(
						.field(ObjectType.boundMethodFieldForMethod, of: target.lowered(in: &context)),
						[.field(ObjectType.boundMethodFieldForReceiver, of: target.lowered(in: &context))] + arguments.lowered(in: &context)
					)
				} else {
					return try .evaluate(target.lowered(in: &context), arguments.lowered(in: &context))
				}
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .let(let definitions, in: let result):
				for definition in definitions {
					context.declare(definition.name, try definition.value.type(in: context))
				}
				defer {
					for definition in definitions.reversed() {
						context.undeclare(definition.name)
					}
				}
				return try .let(definitions.lowered(in: &context), in: result.lowered(in: &context))
				
				case .do(let effects, then: let result):
				return try .do(effects.lowered(in: &context), then: result.lowered(in: &context))
				
			}
		}
		
	}
}
