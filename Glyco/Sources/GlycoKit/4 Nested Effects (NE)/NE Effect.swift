// Glyco © 2021 Constantino Tsarouhas

extension NE {
	
	/// An effect on an NE machine.
	enum Effect : Codable {
		
		/// Assigns the value at `source` to `destination`.
		case assign(destination: Location, source: Source)
		
		/// Assigns the result of `lhs` `operation` `rhs` to `destination`.
		case operation(destination: Location, lhs: Source, operation: BinaryIntegralOperation, rhs: Source)
		
		/// Executes a sequence of effects.
		case sequence([Effect])
		
		/// An integral operation.
		typealias BinaryIntegralOperation = FO.Effect.BinaryIntegralOperation
		
	}
	
	typealias Location = FL.Location
	typealias Source = FO.Source
	
}

extension NE.Effect {
	
	/// The FO representation of `self`.
	var foEffects: [FO.Effect] {
		switch self {
				
			case .assign(destination: let destination, source: let source):
			return [.assign(destination: destination, source: source)]
				
			case .operation(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs):
			return [.operation(destination: destination, lhs: lhs, operation: operation, rhs: rhs)]
				
			case .sequence(let effects):
			return effects.flatMap(\.foEffects)
				
		}
	}
	
}
