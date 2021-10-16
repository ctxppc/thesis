// Glyco © 2021 Constantino Tsarouhas

extension AL {
	
	/// An effect on an AL machine.
	public enum Effect : Codable {
		
		/// Assigns the value at `source` to `destination`.
		case assign(destination: Location, source: Source)
		
		/// Assigns the result of `lhs` `operation` `rhs` to `destination`.
		case operation(destination: Location, lhs: Source, operation: BinaryIntegralOperation, rhs: Source)
		
		/// Executes a sequence of effects.
		case sequence([Effect])
		
		/// An integral operation.
		public typealias BinaryIntegralOperation = NE.Effect.BinaryIntegralOperation
		
	}
	
}

extension AL.Effect {
	
	/// Returns a set of locations (potentially) accessed by `self`.
	public func accessedLocations() -> Set<AL.Location> {
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
	public func neEffect(homes: [AL.Location : NE.Location]) -> NE.Effect {
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
