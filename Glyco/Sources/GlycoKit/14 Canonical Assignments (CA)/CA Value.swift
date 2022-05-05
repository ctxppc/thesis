// Glyco © 2021–2022 Constantino Tsarouhas

extension CA {
	
	public enum Value : Element {
		
		/// A value that evaluates to given source.
		case source(Source)
		
		/// A value that evaluates to result of given operator over given sources.
		case binary(Source, BinaryOperator, Source)
		
		/// A value that evaluates to a unique capability to an uninitialised record of given type.
		case record(RecordType)
		
		/// A value that evaluates to the field with given name in the record at given location.
		case field(Field.Name, of: Location)
		
		/// A value that evaluates to a unique capability to an uninitialised vector of `count` elements of given value type.
		case vector(ValueType, count: Int)
		
		/// A value that evaluates to the element at zero-based position `at` in the vector at `of`.
		case element(of: Location, at: Source)
		
		/// A value that evaluates to a unique capability that can be used for sealing.
		case seal
		
		/// A value that evaluates to the capability in the first given location after sealing it with the seal capability in `with`.
		case sealed(Location, with: Location)
		
	}
	
}
