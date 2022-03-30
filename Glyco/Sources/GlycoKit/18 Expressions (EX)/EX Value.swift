// Glyco © 2021–2022 Constantino Tsarouhas

extension EX {
	
	public enum Value : Codable, Equatable, SimplyLowerable {
		
		/// A value that evaluates to given number.
		case constant(Int)
		
		/// A value that evaluates to the named value associated with given name in the environment.
		case named(Symbol)
		
		/// A value that evaluates to a unique capability to an uninitialised record of given type.
		case record(RecordType)
		
		/// A value that evaluates to the field with given name in the record `of`.
		indirect case field(RecordType.Field.Name, of: Value)
		
		/// A value that evaluates to a unique capability to an uninitialised vector of `count` elements of given data type.
		case vector(ValueType, count: Int)
		
		/// A value that evaluates to the `at`th element of the list `of`.
		indirect case element(of: Value, at: Value)
		
		/// A value that evaluates to a unique capability that can be used for sealing.
		case seal
		
		/// A value that evaluates to the first capability after sealing it with the (second) seal capability.
		indirect case sealed(Value, with: Value)
		
		/// A value that evaluates to *x* *op* *y* where *x* and *y* are given sources and *op* is given operator.
		indirect case binary(Value, BinaryOperator, Value)
		
		/// A value that evaluates to a function evaluated with given arguments.
		case evaluate(Label, [Value])
		
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
				let rec = context.bag.uniqueName(from: "rec")
				return try .let([
					.init(rec, record.lowered(in: &context)),
				], in: .field(fieldName, of: rec))
				
				case .vector(let dataType, count: let count):
				return .vector(dataType, count: count)
				
				case .element(of: let vector, at: let index):
				let vec = context.bag.uniqueName(from: "vec")
				let idx = context.bag.uniqueName(from: "idx")
				return try .let([
					.init(vec, vector.lowered(in: &context)),
					.init(idx, index.lowered(in: &context))
				], in: .element(of: vec, at: .named(idx)))
				
				case .seal:
				return .seal
				
				case .sealed(let cap, with: let seal):
				let c = context.bag.uniqueName(from: "cap")
				let s = context.bag.uniqueName(from: "seal")
				return try .let([
					.init(c, cap.lowered(in: &context)),
					.init(s, seal.lowered(in: &context))
				], in: .sealed(c, with: s))
				
				case .binary(let lhs, let op, let rhs):
				let l = context.bag.uniqueName(from: "lhs")
				let r = context.bag.uniqueName(from: "rhs")
				return try .let([
					.init(l, lhs.lowered(in: &context)),
					.init(r, rhs.lowered(in: &context))
				], in: .binary(.named(l), op, .named(r)))
				
				case .evaluate(let name, let arguments):
				let argumentNamesAndLoweredValues = try arguments.map {
					(context.bag.uniqueName(from: "arg"), try $0.lowered(in: &context))
				}
				return .let(
					argumentNamesAndLoweredValues.map { .init($0.0, $0.1) },
					in: .evaluate(name, argumentNamesAndLoweredValues.map { .named($0.0) })
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
