// Glyco © 2021–2022 Constantino Tsarouhas

extension PR {
	
	/// A value describing the action to take after a block executes its effects.
	public enum Continuation : Codable, Equatable, SimplyLowerable {
		
		/// A continuation that continues to the block with given label.
		case `continue`(to: Label)
		
		/// A continuation that jumps to the block labelled `then` if given predicate holds, or to the block labelled `else` otherwise.
		case branch(if: Predicate, then: Label, else: Label)
		
		/// A continuation that returns to the caller, by jumping to the return capability.
		case `return`
		
		// See protocol.
		public func lowered(in context: inout Context) -> Lower.Continuation {
			switch self {
				
				case .continue(to: let successor):
				return .continue(to: successor)
				
				case .branch(if: .constant(false), then: _, else: let negative):
				return .continue(to: negative)
				
				case .branch(if: .constant(true), then: let affirmative, else: _):
				return .continue(to: affirmative)
				
				case .branch(if: .not(let predicate), then: let affirmative, else: let negative):
				return Self
					.branch(if: predicate, then: negative, else: affirmative)
					.lowered(in: &context)
				
				case .branch(if: .relation(let lhs, let relation, let rhs), then: let affirmative, else: let negative):
				return .branch(lhs, relation, rhs, then: affirmative, else: negative)
				
				case .return:
				return .return
				
			}
		}
		
	}
	
}
