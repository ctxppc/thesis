// Glyco © 2021 Constantino Tsarouhas

extension AL {
	
	/// An effect on an AL machine.
	public enum Effect : Codable {
		
		/// Assigns the value at `source` to `destination`.
		case assign(destination: Location, source: Source)
		
		/// Assigns the result of `lhs` `operation` `rhs` to `destination`.
		case operation(destination: Location, lhs: Source, operation: BinaryOperator, rhs: Source)
		
		/// Executes a sequence of effects.
		case sequence([Effect])
		
		/// Returns a set of locations (potentially) accessed by `self`.
		public func accessedLocations() -> Set<Location> {
			switch self {
				
				case .assign(destination: let destination, source: let source):
				return source.accessedLocations().union([destination])
				
				case .operation(destination: let destination, lhs: let lhs, operation: _, rhs: let rhs):
				return lhs.accessedLocations().union(rhs.accessedLocations()).union([destination])
				
				case .sequence(let effects):
				return .init(effects.lazy.flatMap { $0.accessedLocations() })
				
			}
		}
		
		/// Returns a representation of `self` in a lower language.
		///
		/// - Parameter homes: A dictionary mapping abstract locations to physical locations.
		///
		/// - Returns: A representation of `self` in a lower language.
		public func lowered(homes: [Location : Lower.Location]) -> Lower.Effect {
			switch self {
					
				case .assign(destination: let destination, source: let source):
				return .assign(destination: destination.lowered(homes: homes), source: source.lowered(homes: homes))
					
				case .operation(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs):
				return .operation(destination: destination.lowered(homes: homes), lhs: lhs.lowered(homes: homes), operation: operation, rhs: rhs.lowered(homes: homes))
					
				case .sequence(let effects):
				return .sequence(effects.map { $0.lowered(homes: homes) })
					
			}
		}
		
	}
	
	public typealias BinaryOperator = Lower.BinaryOperator
	
}

public func <- (destination: AL.Location, source: AL.Source) -> AL.Effect {
	.assign(destination: destination, source: source)
}
