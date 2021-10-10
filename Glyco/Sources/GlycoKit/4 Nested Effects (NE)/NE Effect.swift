// Glyco © 2021 Constantino Tsarouhas

/// An effect on an NE machine.
enum NEEffect : Codable {
	
	/// Assigns the value at `source` to `destination`.
	case assign(destination: FLLocation, source: Source)
	
	/// Assigns the result of `lhs` `operation` `rhs` to `destination`.
	case operation(destination: FLLocation, lhs: Source, operation: BinaryIntegralOperation, rhs: Source)
	
	/// Executes a sequence of effects.
	case sequence([NEEffect])
	
	/// A datum source.
	typealias Source = FOSource
	
	/// An integral operation.
	typealias BinaryIntegralOperation = FOEffect.BinaryIntegralOperation
	
}

extension NEEffect {
	
	/// The FO representation of `self`.
	var foEffects: [FOEffect] {
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
