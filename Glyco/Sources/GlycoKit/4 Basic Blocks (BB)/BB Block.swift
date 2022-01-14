// Glyco © 2021–2022 Constantino Tsarouhas

extension BB {
	
	/// A sequence of effects with a single entry and exit point.
	public enum Block : Codable, Equatable, MultiplyLowerable {
		
		/// A block that executes given effects, then jumps to the block labelled `then`.
		case intermediate(Label, [Effect], then: Label)
		
		/// A block that executes given effects, then jumps to the block labelled `then` if *x* `relation` *y*, or to the block labelled `else` otherwise, where *x* is the value of `lhs` and *y* is the value of `rhs`.
		case branch(Label, [Effect], lhs: Source, relation: BranchRelation, rhs: Source, then: Label, else: Label)
		
		/// A block that executes given effects then terminates with `result` of type `type`.
		case final(Label, [Effect], result: Source, type: DataType)
		
		// See protocol.
		public func lowered(in context: inout ()) throws -> [Lower.Effect] {
			switch self {
				
				case .intermediate(let label, let effects, then: let successor):
				if let (first, tail) = try effects.lowered().splittingFirst() {
					return [.labelled(label, first)] + tail + [.jump(to: successor)]
				} else {
					return [.labelled(label, .jump(to: successor))]
				}
				
				case .branch(let label, let effects, lhs: let lhs, relation: let relation, rhs: let rhs, then: let affirmative, else: let negative):
				if let (first, tail) = try effects.lowered().splittingFirst() {
					return [.labelled(label, first)]
						+ tail
						+ [.branch(to: affirmative, lhs, relation, rhs), .jump(to: negative)]
				} else {
					return [.labelled(label, .branch(to: affirmative, lhs, relation, rhs)), .jump(to: negative)]
				}
				
				case .final(let label, let effects, result: let result, type: let type):
				if let (first, tail) = try effects.lowered().splittingFirst() {
					return [.labelled(label, first)] + tail + [.set(type, .register(.a0), to: result), .return]
				} else {
					return [.labelled(label, .set(type, .register(.a0), to: result)), .return]
				}
				
			}
		}
		
	}
	
}
