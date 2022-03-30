// Glyco © 2021–2022 Constantino Tsarouhas

extension DF {
	
	public enum Value : Codable, Equatable, SimplyLowerable {
		
		/// A value that evaluates to the value of given source.
		case source(Source)
		
		/// A value that evaluates to *x* *op* *y* where *x* and *y* are given sources and *op* is given operator.
		case binary(Source, BinaryOperator, Source)
		
		/// A value that evaluates to a unique capability to an uninitialised record of given type.
		case record(RecordType)
		
		/// A value that evaluates to the field with given name in the record at given location.
		case field(RecordType.Field.Name, of: Location)
		
		/// A value that evaluates to a unique capability to an uninitialised vector of `count` elements of given data type.
		case vector(ValueType, count: Int)
		
		/// A value that evaluates to the element at zero-based position `at` in the vector at `of`.
		case element(of: Location, at: Source)
		
		/// A value that evaluates to a unique capability that can be used for sealing.
		case seal
		
		/// A value that evaluates to a function evaluated with given arguments.
		case evaluate(Label, [Source])
		
		/// A value that evaluates to the value of `then` if the predicate holds, or to the value of `else` otherwise.
		indirect case `if`(Predicate, then: Value, else: Value)
		
		/// A value that evaluates to given value after associating zero or more values with a name.
		indirect case `let`([Definition], in: Value)
		
		/// A value that evaluates to given value after performing given effects.
		indirect case `do`([Effect], then: Value)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Value {
			switch self {
				
				case .source(let source):
				return .source(source)
				
				case .binary(let lhs, let op, let rhs):
				return .binary(lhs, op, rhs)
				
				case .record(let type):
				return .record(type)
				
				case .field(let fieldName, of: let record):
				return .field(fieldName, of: record)
				
				case .vector(let dataType, count: let count):
				return .vector(dataType, count: count)
				
				case .element(of: let vector, at: let index):
				return .element(of: vector, at: index)
				
				case .seal:
				return .seal
				
				case .evaluate(let name, let arguments):
				return .evaluate(name, arguments)
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .let(let definitions, in: let body):
				return try .do(definitions.lowered(in: &context), then: body.lowered(in: &context))
				
				case .do(let effects, then: let value):
				return try .do(effects.lowered(in: &context), then: value.lowered(in: &context))
				
			}
		}
		
	}
	
}
