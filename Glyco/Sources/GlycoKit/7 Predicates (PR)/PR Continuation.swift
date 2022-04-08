// Glyco © 2021–2022 Constantino Tsarouhas

extension PR {
	
	/// A value describing the action to take after a block executes its effects.
	public enum Continuation : Codable, Equatable, SimplyLowerable {
		
		/// A continuation that continues to the block with given label.
		case `continue`(to: Label)
		
		/// A continuation that jumps to the block labelled `then` if given predicate holds, or to the block labelled `else` otherwise.
		case branch(if: Predicate, then: Label, else: Label)
		
		/// A continuation that calls the procedure with given target capability then returns to the block labelled `returnPoint`.
		case call(Source, returnPoint: Label)
		
		/// A continuation that invokes the procedure with given target code capability and data capability, then returns to the block labelled `returnPoint`.
		///
		/// The code and data capabilities must be sealed with the same object type.
		case callSealed(Source, data: Source, returnPoint: Label)
		
		/// A continuation that returns control to the caller with given target code capability (which is usually `cra`).
		case `return`(to: Source)
		
		// See protocol.
		public func lowered(in context: inout Context) -> Lower.Continuation {
			switch self {
				
				case .continue(to: let successor):
				return .continue(to: successor)
				
				case .branch(if: .constant(false), then: _, else: let negative):
				return .continue(to: negative)
				
				case .branch(if: .constant(true), then: let affirmative, else: _):
				return .continue(to: affirmative)
				
				case .branch(if: .relation(let lhs, let relation, let rhs), then: let affirmative, else: let negative):
				return .branch(lhs, relation, rhs, then: affirmative, else: negative)
				
				case .call(let target, returnPoint: let returnPoint):
				return .call(target, returnPoint: returnPoint)
				
				case .callSealed(let target, data: let data, returnPoint: let returnPoint):
				return .callSealed(target, data: data, returnPoint: returnPoint)
				
				case .return(to: let caller):
				return .return(to: caller)
				
			}
		}
		
	}
	
}
