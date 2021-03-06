// Glyco © 2021–2022 Constantino Tsarouhas

import Sisp

extension Λ {
	public enum Value : PartiallyStringCodable, PartiallyIntCodable, SimplyLowerable, Element {
		
		/// A value that evaluates to given number.
		case constant(Int)
		
		/// A value that evaluates to the named value associated with given name in the environment.
		case named(Symbol)
		
		/// A value that evaluates to a unique capability to a record with given entries.
		indirect case record([RecordEntry])
		
		/// A value that evaluates to the field with given name in the record `of`.
		indirect case field(Field.Name, of: Value)
		
		/// A value that evaluates to a unique capability to a vector of `count` copies of given value.
		indirect case vector(Value, count: Int)
		
		/// A value that evaluates to the `at`th element of the list `of`.
		indirect case element(of: Value, at: Value)
		
		/// A value that evaluates to an anonymous function with given parameters, result type, and result.
		///
		/// Enclosing definitions are not available within the lambda body.
		indirect case λ(takes: [Parameter], returns: ValueType, in: Result)
		
		/// A value that evaluates to a unique capability that can be used for sealing.
		case seal
		
		/// A value that evaluates to the first capability after sealing it with the (second) seal capability.
		indirect case sealed(Value, with: Value)
		
		/// A value that evaluates to *x* *op* *y* where *x* and *y* are given sources and *op* is given operator.
		indirect case binary(Value, BinaryOperator, Value)
		
		/// A value that evaluates to given function evaluated with given arguments.
		indirect case evaluate(Value, [Value])
		
		/// A value that evaluates to the value of `then` if the predicate holds, or to the value of `else` otherwise.
		indirect case `if`(Predicate, then: Value, else: Value)
		
		/// A value that evaluates to given value after associating zero or more values with a name.
		///
		/// Definitions using a lambda value are immediately available in the lambda body and can be used for recursion.
		indirect case `let`([Definition], in: Value)
		
		/// A value that evaluates to given value after performing given effects.
		indirect case `do`([Effect], then: Value)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Value {
			switch self {
				
				case .constant(let value):
				return .constant(value)
					
				case .named(let symbol):
				return .named(symbol)
				
				case .record(let entries):
				return .record(try entries.lowered(in: &context))
				
				case .field(let fieldName, of: let record):
				return try .field(fieldName, of: record.lowered(in: &context))
				
				case .vector(let repeatedElement, count: let count):
				return .vector(try repeatedElement.lowered(in: &context), count: count)
				
				case .element(of: let vector, at: let index):
				return try .element(of: vector.lowered(in: &context), at: index.lowered(in: &context))
				
				case .λ(takes: let parameters, returns: let resultType, in: let result):
				let name = context.labels.uniqueName(from: "anon")
				context.lambdaFunctions.append(
					.init(name, takes: parameters, returns: resultType, in: try result.lowered(in: &context))
				)
				return .function(name)
				
				case .seal:
				return .seal
				
				case .sealed(let cap, with: let seal):
				return try .sealed(cap.lowered(in: &context), with: seal.lowered(in: &context))
				
				case .binary(let lhs, let op, let rhs):
				return try .binary(lhs.lowered(in: &context), op, rhs.lowered(in: &context))
				
				case .evaluate(let function, let arguments):
				return try .evaluate(function.lowered(in: &context), arguments.lowered(in: &context))
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(
					predicate.lowered(in: &context),
					then: affirmative.lowered(in: &context),
					else: negative.lowered(in: &context)
				)
				
				case .let(let definitions, in: let body):
				return try .let(definitions.lowered(in: &context), in: body.lowered(in: &context))
				
				case .do(let effects, then: let value):
				return try .do(effects.lowered(in: &context), then: value.lowered(in: &context))
				
			}
		}
		
	}
}
