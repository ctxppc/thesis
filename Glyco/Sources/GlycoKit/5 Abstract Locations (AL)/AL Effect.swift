// Glyco © 2021 Constantino Tsarouhas

/// An effect on an AL machine.
enum ALEffect : Codable {
	
	/// Assigns the value at `source` to `destination`.
	case assign(destination: ALLocation, source: ALSource)
	
	/// Assigns the result of `lhs` `operation` `rhs` to `destination`.
	case operation(destination: ALLocation, lhs: ALSource, operation: BinaryIntegralOperation, rhs: ALSource)
	
	/// Executes a sequence of effects.
	case sequence([ALEffect])
	
	/// An integral operation.
	typealias BinaryIntegralOperation = NEEffect.BinaryIntegralOperation
	
}

extension ALEffect {
	
	/// Returns a set of locations (potentially) accessed by `self`.
	func accessedLocations() -> Set<ALLocation> {
		switch self {
			
			case .assign(destination: let destination, source: let source):
			return source.accessedLocations().union([destination])
			
			case .operation(destination: let destination, lhs: let lhs, operation: _, rhs: let rhs):
			return lhs.accessedLocations().union(rhs.accessedLocations()).union([destination])
			
			case .sequence(let effects):
			return .init(effects.lazy.flatMap { $0.accessedLocations() })
			
		}
	}
	
	/// Returns an NE representation of `self`.
	///
	/// - Parameter homes: A dictionary mapping abstract locations to physical locations.
	///
	/// - Returns: An NE representation of `self`.
	func neEffect(homes: [ALLocation : NELocation]) -> NEEffect {
		switch self {
				
			case .assign(destination: let destination, source: let source):
			return .assign(destination: destination.neLocation(homes: homes), source: source.neSource(homes: homes))
				
			case .operation(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs):
			return .operation(destination: destination.neLocation(homes: homes), lhs: lhs.neSource(homes: homes), operation: operation, rhs: rhs.neSource(homes: homes))
				
			case .sequence(let effects):
			return .sequence(effects.map { $0.neEffect(homes: homes) })
				
		}
	}
	
}
