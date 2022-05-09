// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit
import Foundation
import Sisp

extension CL {
	public enum Value : PartiallyStringCodable, PartiallyIntCodable, SimplyLowerable, Element {
		
		/// A value that evaluates to an unsealed capability to the current object.
		///
		/// `self` is not valid outside methods.
		case `self`
		
		/// A value that evaluates to given number.
		case constant(Int)
		
		/// A value that evaluates to the named value associated with given name in the environment.
		case named(Symbol)
		
		/// A value that evaluates to a unique capability to an uninitialised record of given type.
		case record(RecordType)
		
		/// A value that evaluates to the field with given name in the record `of`.
		indirect case field(Field.Name, of: Value)
		
		/// A value that evaluates to a unique capability to an uninitialised vector of `count` elements of given data type.
		case vector(ValueType, count: Int)
		
		/// A value that evaluates to the `at`th element of the list `of`.
		indirect case element(of: Value, at: Value)
		
		/// A value that evaluates to an anonymous function with given parameters, result type, and result.
		indirect case λ(takes: [Parameter], returns: ValueType, in: Result)
		
		/// A value that evaluates to a unique capability to an object constructed with given arguments.
		case object(TypeName, [Value])
		
		/// A value that evaluates to *x* *op* *y* where *x* and *y* are given sources and *op* is given operator.
		indirect case binary(Value, BinaryOperator, Value)
		
		/// A value that evaluates to given function evaluated with given arguments.
		indirect case evaluate(Value, [Value])
		
		/// A value that messages the object with given object capability, method name, and arguments.
		indirect case message(Value, Method.Name, [Value])
		
		/// A value that evaluates to the value of `then` if the predicate holds, or to the value of `else` otherwise.
		indirect case `if`(Predicate, then: Value, else: Value)
		
		/// A value that evaluates to given value after associating zero or more values with a name.
		indirect case `let`([Definition], in: Value)
		
		/// A value that evaluates to given value after associating zero or more types with a name.
		indirect case letType([TypeDefinition], in: Value)
		
		/// A value that evaluates to given value after performing given effects.
		indirect case `do`([Effect], then: Value)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Value {
			switch self {
				
				case .self:
				return .named(Method.selfName)
				
				case .constant(let value):
				return .constant(value)
				
				case .named(let symbol):
				return .named(symbol)
				
				case .record(let type):
				return .record(type)
				
				case .field(let fieldName, of: let record):
				return .field(fieldName, of: try record.lowered(in: &context))
				
				case .vector(let elementType, count: let count):
				return .vector(elementType, count: count)
				
				case .λ(takes: let parameters, returns: let resultType, in: let body):
				return try .λ(takes: parameters, returns: resultType, in: body.lowered(in: &context))
				
				case .element(of: let vector, at: let index):
				return try .element(of: vector.lowered(in: &context), at: index.lowered(in: &context))
				
				case .object(let typeName, let arguments):
				return .object(typeName, try arguments.lowered(in: &context))
				
				case .binary(let lhs, let op, let rhs):
				return try .binary(lhs.lowered(in: &context), op, rhs.lowered(in: &context))
				
				case .evaluate(let function, let arguments):
				return try .evaluate(function.lowered(in: &context), arguments.lowered(in: &context))
				
				case .message(let receiver, let methodName, let arguments):
				return try .message(receiver.lowered(in: &context), methodName, arguments.lowered(in: &context))
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .let(let definitions, in: let body):
				return try .let(definitions.lowered(in: &context), in: body.lowered(in: &context))
				
				case .letType(let typeDefinitions, in: let body):
				return try .letType(typeDefinitions, in: body.lowered(in: &context))
				
				case .do(let effects, then: let value):
				return try .do(effects.lowered(in: &context), then: value.lowered(in: &context))
				
			}
		}
		
	}
}
