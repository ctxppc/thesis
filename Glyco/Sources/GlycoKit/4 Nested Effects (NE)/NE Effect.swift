// Glyco © 2021 Constantino Tsarouhas

extension NE {
	
	/// An effect on an NE machine.
	public enum Effect : Codable {
		
		/// Assigns the value at `source` to `destination`.
		case assign(destination: Location, source: Source)
		
		/// Assigns the result of `lhs` `operation` `rhs` to `destination`.
		case operation(destination: Location, lhs: Source, operation: BinaryOperation, rhs: Source)
		
		/// Executes a sequence of effects.
		case sequence([Effect])
		
		/// An integral operation.
		public typealias BinaryOperation = Lower.Effect.BinaryOperation
		
		/// Returns a representation of `self` in a lower language.
		public func lowered() -> [Lower.Effect] {
			switch self {
				
				case .assign(destination: let destination, source: let source):
				return [.assign(destination: destination, source: source)]
				
				case .operation(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs):
				return [.operation(destination: destination, lhs: lhs, operation: operation, rhs: rhs)]
				
				case .sequence(let effects):
				return effects.flatMap { $0.lowered() }
				
			}
		}
		
	}
	
	public typealias Location = FL.Location
	public typealias Source = FO.Source
	
}
