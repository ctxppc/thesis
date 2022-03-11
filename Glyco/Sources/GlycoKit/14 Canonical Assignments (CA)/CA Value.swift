// Glyco © 2021–2022 Constantino Tsarouhas

extension CA {
	
	public enum Value : Codable, Equatable {
		
		/// A value that evaluates to given source.
		case source(Source)
		
		/// A value that evaluates to result of given operator over given sources.
		case binary(Source, BinaryOperator, Source)
		
		/// A value that evaluates to a unique capability to an uninitialised record of given type.
		case record(RecordType)
		
		/// A value that evaluates to the field with given name in the record at given location.
		case field(RecordType.Field.Name, of: Location)
		
		/// A value that evaluates to a unique capability to an uninitialised vector of `count` elements of given value type.
		case vector(ValueType, count: Int)
		
		/// A value that evaluates to the element at zero-based position `at` in the vector at `of`.
		case element(of: Location, at: Source)
		
	}
	
}
