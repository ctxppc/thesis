// Glyco © 2021–2022 Constantino Tsarouhas

import Sisp

extension EX {
	
	public enum Value : PartiallyStringCodable, PartiallyIntCodable, Equatable, SimplyLowerable {
		
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
		
		/// A value representing a globally defined function with given name.
		case function(Label)
		
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
		indirect case `let`([Definition], in: Value)
		
		/// A value that evaluates to given value after performing given effects.
		indirect case `do`([Effect], then: Value)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Value {
			switch self {
				
				case .constant(let value):
				return .source(.constant(value))
					
				case .named(let symbol):
				return .source(.named(symbol))
				
				case .record(let type):
				return .record(type)
				
				case .field(let fieldName, of: let record):
				let rec = context.symbols.uniqueName(from: "rec")
				return try .let([
					.init(rec, record.lowered(in: &context)),
				], in: .field(fieldName, of: rec))
				
				case .vector(let valueType, count: let count):
				return .vector(valueType, count: count)
				
				case .element(of: let vector, at: let index):
				let vec = context.symbols.uniqueName(from: "vec")
				let idx = context.symbols.uniqueName(from: "idx")
				return try .let([
					.init(vec, vector.lowered(in: &context)),
					.init(idx, index.lowered(in: &context))
				], in: .element(of: vec, at: .named(idx)))
				
				case .function(let name):
				return .source(.function(name))
				
				case .seal:
				return .seal
				
				case .sealed(let cap, with: let seal):
				let c = context.symbols.uniqueName(from: "cap")
				let s = context.symbols.uniqueName(from: "seal")
				return try .let([
					.init(c, cap.lowered(in: &context)),
					.init(s, seal.lowered(in: &context))
				], in: .sealed(c, with: s))
				
				case .binary(let lhs, let op, let rhs):
				let l = context.symbols.uniqueName(from: "lhs")
				let r = context.symbols.uniqueName(from: "rhs")
				return try .let([
					.init(l, lhs.lowered(in: &context)),
					.init(r, rhs.lowered(in: &context))
				], in: .binary(.named(l), op, .named(r)))
				
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
				
				case .let(let definitions, in: let body):
				return try .let(definitions.lowered(in: &context), in: body.lowered(in: &context))
				
				case .do(let effects, then: let value):
				return try .do(effects.lowered(in: &context), then: value.lowered(in: &context))
				
			}
		}
		
	}
	
}
