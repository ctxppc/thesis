// Glyco © 2021 Constantino Tsarouhas

extension AL {
	
	/// An effect on an AL machine.
	public enum Effect : Codable {
		
		/// Assigns the value at `source` to `destination`.
		case copy(destination: Location, source: Source)
		
		/// Assigns the result of `lhs` `operation` `rhs` to `destination`.
		case compute(destination: Location, lhs: Source, operation: BinaryOperator, rhs: Source)
		
		/// An effect that jumps to `target` if *x* `relation` *y*, where *x* is the value of `lhs` and *y* is the value of `rhs`.
		case branch(target: Label, lhs: Source, relation: BranchRelation, rhs: Source)
		
		/// Executes a sequence of effects.
		case `do`([Effect])
		
		/// An effect that can jumped to using given label.
		indirect case labelled(Label, Effect)
		
		/// Returns a set of locations (potentially) accessed by `self`.
		public func accessedLocations() -> Set<Location> {
			switch self {
				
				case .copy(destination: let destination, source: let source):
				return source.accessedLocations().union([destination])
				
				case .compute(destination: let destination, lhs: let lhs, operation: _, rhs: let rhs):
				return lhs.accessedLocations().union(rhs.accessedLocations()).union([destination])
				
				case .do(let effects):
				return .init(effects.lazy.flatMap { $0.accessedLocations() })
				
				case .branch(target: _, lhs: let lhs, relation: _, rhs: let rhs):
				return lhs.accessedLocations().union(rhs.accessedLocations())
				
				case .labelled(_, let effect):
				return effect.accessedLocations()
				
			}
		}
		
		/// Returns a representation of `self` in a lower language.
		///
		/// - Parameter homes: A dictionary mapping abstract locations to physical locations.
		///
		/// - Returns: A representation of `self` in a lower language.
		public func lowered(homes: [Location : Lower.Location]) -> Lower.Effect {
			switch self {
					
				case .copy(destination: let destination, source: let source):
				return .copy(destination: destination.lowered(homes: homes), source: source.lowered(homes: homes))
					
				case .compute(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs):
				return .compute(destination: destination.lowered(homes: homes), lhs: lhs.lowered(homes: homes), operation: operation, rhs: rhs.lowered(homes: homes))
					
				case .do(let effects):
				return .do(effects.map { $0.lowered(homes: homes) })
					
				case .branch(target: let target, lhs: let lhs, relation: let relation, rhs: let rhs):
				return .branch(target: target, lhs: lhs.lowered(homes: homes), relation: relation, rhs: rhs.lowered(homes: homes))
				
				case .labelled(let label, let effect):
				return .labelled(label, effect.lowered(homes: homes))
				
			}
		}
		
	}
	
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias Label = Lower.Label
	public typealias BranchRelation = Lower.BranchRelation
	
}

public func <- (destination: AL.Location, source: AL.Source) -> AL.Effect {
	.copy(destination: destination, source: source)
}
