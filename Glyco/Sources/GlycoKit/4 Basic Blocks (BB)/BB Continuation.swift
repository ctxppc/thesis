// Glyco © 2021–2022 Constantino Tsarouhas

extension BB {
	
	/// A value describing the action to take after a block executes its effects.
	public enum Continuation : Codable, Equatable, MultiplyLowerable {
		
		/// A continuation that continues to the block with given label.
		case `continue`(to: Label)
		
		/// A continuation that jumps to the block labelled `then` if *x* *R* *y*, or to the block labelled `else` otherwise, where *x* is the value of the first source, *y* is the value of the second source, and *R* is the relation.
		case branch(Source, BranchRelation, Source, then: Label, else: Label)
		
		/// A continuation that jumps to the procedure with given label then returns to the block labelled `returnPoint`.
		case call(Label, returnPoint: Label)
		
		/// A continuation that returns to the caller, by jumping to the return capability.
		case `return`
		
		// See protocol.
		public func lowered(in context: inout ()) throws -> [Lower.Effect] {
			switch self {
				
				case .continue(to: let successor):
				return [.jump(to: successor)]
				
				case .branch(let lhs, let relation, let rhs, then: let affirmative, else: let negative):
				return [.branch(to: affirmative, lhs, relation, rhs), .jump(to: negative)]
				
				case .call(let name, returnPoint: let returnPoint):
				return [.call(name), .jump(to: returnPoint)]
				
				case .return:
				return [.return]
				
			}
		}
		
	}
	
}
