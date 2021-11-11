// Glyco © 2021 Constantino Tsarouhas

extension BB {
	
	/// An effect on an BB machine.
	public enum Effect : Codable, Equatable, MultiplyLowerable {
		
		/// An effect that retrieves the value in `source` and puts it in `destination`.
		case copy(destination: Location, source: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `destination`.
		case compute(destination: Location, lhs: Source, operation: BinaryOperator, rhs: Source)
		
		// See protocol.
		public func lowered(in context: inout ()) -> [Lower.Effect] {
			switch self {
				
				case .copy(destination: let destination, source: let source):
				return [.copy(destination: destination, source: source)]
				
				case .compute(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs):
				return [.compute(destination: destination, lhs: lhs, operation: operation, rhs: rhs)]
				
			}
		}
		
	}
	
	public typealias Location = Lower.Location
	public typealias Source = Lower.Source
	public typealias BinaryOperator = Lower.BinaryOperator
	
}
