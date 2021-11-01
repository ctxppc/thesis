// Glyco © 2021 Constantino Tsarouhas

extension RV {
	
	/// A relation between values that can be used to decide whether to take a branch.
	public enum BranchRelation : String, Codable {
		
		/// The branch is taken if the values are equal.
		case equal = "eq"
		
		/// The branch is taken if the values are not equal.
		case unequal = "ne"
		
		/// The branch is taken if the first value is less than the second value.
		case less = "lt"
		
		/// The branch is taken if the first value is greater than or equal to the second value.
		case greaterOrEqual = "ge"
		
	}
	
}