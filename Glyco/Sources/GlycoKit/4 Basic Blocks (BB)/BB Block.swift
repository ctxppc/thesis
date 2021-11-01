// Glyco © 2021 Constantino Tsarouhas

extension BB {
	
	/// A sequence of effects with a single entry and exit point.
	public enum Block : Codable {
		
		/// A block labelled `label` that executes `effects`, then jumps to the block labelled `successor`.
		case intermediate(label: Label, effects: [Effect], successor: Label)
		
		/// A block labelled `label` that executes `effects`, then jumps to either the block labelled `affirmative` if *x* `relation` *y*, or to the block labelled `negative` otherwise, where *x* is the value of `lhs` and *y* is the value of `rhs`.
		case branch(label: Label, effects: [Effect], lhs: Source, relation: BranchRelation, rhs: Source, affirmative: Label, negative: Label)
		
		/// A block that executes `effects` then terminates with `result`
		case final(label: Label, effects: [Effect], result: Source)
		
		/// Returns a representation of `self` in a lower language.
		public func lowered() -> [Lower.Effect] {
			switch self {
					
				case .intermediate(label: let label, effects: let effects, successor: let successor):
				if let (first, tail) = effects.flatMap({ $0.lowered() }).splittingFirst() {
					return [.labelled(label, first)] + tail + [.jump(target: successor)]
				} else {
					return [.labelled(label, .jump(target: successor))]
				}
					
				case .branch(label: let label, effects: let effects,
							 lhs: let lhs, relation: let relation, rhs: let rhs,
							 affirmative: let affirmative, negative: let negative):
				if let (first, tail) = effects.flatMap({ $0.lowered() }).splittingFirst() {
					return [.labelled(label, first)]
						+ tail
						+ [.branch(target: affirmative, lhs: lhs, relation: relation, rhs: rhs), .jump(target: negative)]
				} else {
					return [.labelled(label, .branch(target: affirmative, lhs: lhs, relation: relation, rhs: rhs)), .jump(target: negative)]
				}
					
				case .final(let label, let effects, let result):
				if let (first, tail) = effects.flatMap({ $0.lowered() }).splittingFirst() {
					return [.labelled(label, first)] + tail + [.copy(destination: .register(.a0), source: result), .return]
				} else {
					return [.labelled(label, .copy(destination: .register(.a0), source: result)), .return]
				}
					
			}
		}
		
	}
	
}
