// Glyco © 2021 Constantino Tsarouhas

extension PR {
	
	/// A sequence of effects with a single entry and exit point.
	public enum Block : Codable, Equatable, SimplyLowerable {
		
		/// A block labelled `label` that executes `effects`, then jumps to the block labelled `successor`.
		case intermediate(label: Label, effects: [Effect], successor: Label)
		
		/// A block labelled `label` that executes `effects`, then jumps to either the block labelled `affirmative` if `predicate` holds, or to the block labelled `negative` otherwise.
		case branch(label: Label, effects: [Effect], predicate: Predicate, affirmative: Label, negative: Label)
		
		/// A block that executes `effects` then terminates with `result`
		case final(label: Label, effects: [Effect], result: Source)
		
		// See protocol.
		public func lowered(in context: inout ()) -> Lower.Block {
			switch self {
				
				case .intermediate(label: let label, effects: let effects, successor: let successor):
				return .intermediate(label: label, effects: effects, successor: successor)
				
				case .branch(label: let label, effects: let effects,
							 predicate: .constant(false),
							 affirmative: _, negative: let negative):
				return .intermediate(label: label, effects: effects, successor: negative)
				
				case .branch(label: let label, effects: let effects,
							 predicate: .constant(true),
							 affirmative: let affirmative, negative: _):
				return .intermediate(label: label, effects: effects, successor: affirmative)
				
				case .branch(label: let label, effects: let effects,
							 predicate: .not(let predicate),
							 affirmative: let affirmative, negative: let negative):
				return Self.branch(label: label, effects: effects, predicate: predicate, affirmative: negative, negative: affirmative)
						.lowered()
				
				case .branch(label: let label, effects: let effects,
							 predicate: .relation(lhs: let lhs, relation: let relation, rhs: let rhs),
							 affirmative: let affirmative, negative: let negative):
				return .branch(label: label, effects: effects, lhs: lhs, relation: relation, rhs: rhs, affirmative: affirmative, negative: negative)
				
				case .final(label: let label, effects: let effects, result: let result):
				return .final(label: label, effects: effects, result: result)
				
			}
		}
		
		/// The block's label.
		public var label: Label {
			switch self {
				case .intermediate(label: let label, effects: _, successor: _):							return label
				case .branch(label: let label, effects: _, predicate: _, affirmative: _, negative: _):	return label
				case .final(label: let label, effects: _, result: _):									return label
			}
		}
		
	}
	
}
