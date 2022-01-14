// Glyco © 2021–2022 Constantino Tsarouhas

extension PR {
	
	/// A sequence of effects with a single entry and exit point.
	public enum Block : Codable, Equatable, SimplyLowerable {
		
		/// A block that executes given effects, then jumps to the block labelled `then`.
		case intermediate(Label, [Effect], then: Label)
		
		/// A block that executes given effects, then jumps to either the block labelled `then` if `if` holds, or to the block labelled `else` otherwise.
		case branch(Label, [Effect], if: Predicate, then: Label, else: Label)
		
		/// A block that executes given effects then terminates with `result`
		case final(Label, [Effect], result: Source, type: DataType)
		
		// See protocol.
		public func lowered(in context: inout ()) throws -> Lower.Block {
			switch self {
				
				case .intermediate(let label, let effects, then: let successor):
				return .intermediate(label, effects, then: successor)
				
				case .branch(let label, let effects, if: .constant(false), then: _, else: let negative):
				return .intermediate(label, effects, then: negative)
				
				case .branch(let label, let effects, if: .constant(true), then: let affirmative, else: _):
				return .intermediate(label, effects, then: affirmative)
				
				case .branch(let label, let effects, if: .not(let predicate), then: let affirmative, else: let negative):
				return try Self.branch(label, effects, if: predicate, then: negative, else: affirmative).lowered()
				
				case .branch(let label, let effects, if: .relation(let lhs, let relation, let rhs), then: let affirmative, else: let negative):
				return .branch(label, effects, lhs: lhs, relation: relation, rhs: rhs, then: affirmative, else: negative)
				
				case .final(let label, let effects, result: let result, type: let type):
				return .final(label, effects, result: result, type: type)
				
			}
		}
		
		/// The block's label.
		public var label: Label {
			switch self {
				case .intermediate(let label, _, then: _):				return label
				case .branch(let label, _, if: _, then: _, else: _):	return label
				case .final(let label, _, result: _, type: _):			return label
			}
		}
		
	}
	
}
