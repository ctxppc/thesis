// Glyco © 2021–2022 Constantino Tsarouhas

extension CA {
	
	public enum Value : Codable, Equatable {
		
		/// The value is given source.
		case source(Source)
		
		/// The value is the result of a binary operation over two sources.
		case binary(Source, BinaryOperator, Source)
		
	}
	
}
