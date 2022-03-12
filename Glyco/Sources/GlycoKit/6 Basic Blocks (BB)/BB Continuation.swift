// Glyco © 2021–2022 Constantino Tsarouhas

extension BB {
	
	/// A value describing the action to take after a block executes its effects.
	public enum Continuation : Codable, Equatable {
		
		/// A continuation that continues to the block with given label.
		case `continue`(to: Label)
		
		/// A continuation that jumps to the block labelled `then` if *x* *R* *y*, or to the block labelled `else` otherwise, where *x* is the value of the first source, *y* is the value of the second source, and *R* is the relation.
		case branch(Source, BranchRelation, Source, then: Label, else: Label)
		
		/// A continuation that jumps to the procedure with given label then returns to the block labelled `returnPoint`.
		case call(Label, returnPoint: Label)
		
		/// A continuation that jumps to the address in `target` after unsealing it, and puts the datum in `data` in `invocationData` after unsealing it.
		case invoke(target: Source, data: Source)
		
		/// A continuation that jumps to given runtime routine then returns to the block labelled `returnPoint`.
		///
		/// The calling convention is dictated by the routine.
		case invokeRuntimeRoutine(RuntimeRoutine, returnPoint: Label)
		
		/// A continuation that returns to the caller, by jumping to the return capability.
		case `return`
		
	}
	
}
