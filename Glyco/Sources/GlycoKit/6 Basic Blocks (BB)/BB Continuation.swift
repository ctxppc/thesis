// Glyco © 2021–2022 Constantino Tsarouhas

extension BB {
	
	/// A value describing the action to take after a block executes its effects.
	public enum Continuation : Codable, Equatable {
		
		/// A continuation that continues to the block with given label.
		case `continue`(to: Label)
		
		/// A continuation that jumps to the block labelled `then` if *x* *R* *y*, or to the block labelled `else` otherwise, where *x* is the value of the first source, *y* is the value of the second source, and *R* is the relation.
		case branch(Source, BranchRelation, Source, then: Label, else: Label)
		
		/// A continuation that calls the procedure with given label then returns to the block labelled `returnPoint`.
		case call(Label, returnPoint: Label)
		
		/// A continuation that returns control to the caller with given target code capability (which is usually `cra`).
		case `return`(to: Source)
		
		/// Replaces any occurrences of `removedBlockName` by `newBlockName`.
		mutating func substitute(_ removedBlockName: Block.Name, by newBlockName: Block.Name) {
			
			func substituting(_ label: Label) -> Label {
				guard label == removedBlockName else { return label }
				return newBlockName
			}
			
			switch self {
				
				case .continue(to: let successor):
				self = .continue(to: substituting(successor))
				
				case .branch(let lhs, let relation, let rhs, then: let affirmative, else: let negative):
				self = .branch(lhs, relation, rhs, then: substituting(affirmative), else: substituting(negative))
				
				case .call(let name, returnPoint: let returnPoint):
				self = .call(name, returnPoint: substituting(returnPoint))
				
				case .return:
				break
				
			}
			
		}
		
	}
	
}
