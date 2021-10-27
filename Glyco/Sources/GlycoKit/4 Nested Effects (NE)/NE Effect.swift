// Glyco © 2021 Constantino Tsarouhas

extension NE {
	
	/// An effect on an NE machine.
	public enum Effect : Codable {
		
		/// An effect that retrieves the value in `source` and puts it in `destination`.
		case copy(destination: Location, source: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `destination`.
		case compute(destination: Location, lhs: Source, operation: BinaryOperator, rhs: Source)
		
		/// An effect that jumps to `target` if *x* `relation` *y*, where *x* is the value of `lhs` and *y* is the value of `rhs`.
		case branch(target: Label, lhs: Source, relation: BranchRelation, rhs: Source)
		
		/// An effect that consists of a sequence of effects.
		case `do`([Effect])
		
		/// An effect that can jumped to using given label.
		indirect case labelled(Label, Effect)
		
		/// Returns a representation of `self` in a lower language.
		public func lowered() -> [Lower.Effect] {
			switch self {
				
				case .copy(destination: let destination, source: let source):
				return [.copy(destination: destination, source: source)]
				
				case .compute(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs):
				return [.compute(destination: destination, lhs: lhs, operation: operation, rhs: rhs)]
				
				case .branch(target: let target, lhs: let lhs, relation: let relation, rhs: let rhs):
				return [.branch(target: target, lhs: lhs, relation: relation, rhs: rhs)]
				
				case .do(let effects):
				return effects.flatMap { $0.lowered() }
				
				case .labelled(let label, let effect):
				guard let (first, tail) = effect.lowered().splittingFirst() else { return [.labelled(label, .nop)] }
				return [.labelled(label, first)].appending(contentsOf: tail)
				
			}
		}
		
	}
	
	public typealias Location = Lower.Location
	public typealias Source = Lower.Source
	public typealias BinaryOperator = Lower.BinaryOperator
	public typealias Label = Lower.Label
	public typealias BranchRelation = Lower.BranchRelation
	
}
