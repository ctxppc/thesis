// Glyco © 2021–2022 Constantino Tsarouhas

extension CV {
	
	public enum Value : Element {
		
		/// A value that evaluates to the value of given source.
		case source(Source)
		
		/// A value that evaluates to *x* *op* *y* where *x* and *y* are given sources and *op* is given operator.
		case binary(Source, BinaryOperator, Source)
		
		/// A value that evaluates to a unique capability to an uninitialised record of given type.
		case record(RecordType)
		
		/// A value that evaluates to the field with given name in the record at given location.
		case field(Field.Name, of: Location)
		
		/// A value that evaluates to a unique capability to an uninitialised vector of `count` elements of given data type.
		case vector(ValueType, count: Int)
		
		/// A value that evaluates to the element at zero-based position `at` in the vector at `of`.
		case element(of: Location, at: Source)
		
		/// A value that evaluates to a unique capability that can be used for sealing.
		case seal
		
		/// A value that evaluates to the capability in the first given location after sealing it with the seal capability in `with`.
		case sealed(Location, with: Location)
		
		/// A value that performs the procedure with given target code capability with given arguments and evaluates to that procedure's result.
		case evaluate(Source, [Source])
		
		/// A value that evaluates to the value of `then` if the predicate holds, or to the value of `else` otherwise.
		indirect case `if`(Predicate, then: Value, else: Value)
		
		/// A value that performs some effect then evaluates to the value of `then`.
		indirect case `do`([Effect], then: Value)
		
	}
	
}
