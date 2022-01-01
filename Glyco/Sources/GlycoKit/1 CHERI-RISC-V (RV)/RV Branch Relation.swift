// Glyco © 2021–2022 Constantino Tsarouhas

extension RV {
	
	/// A relation between values that can be used to decide whether to take a branch.
	public enum BranchRelation : String, Equatable, Codable {
		
		/// The branch is taken if the values are equal.
		case equal = "eq"
		
		/// The branch is taken if the values are not equal.
		case unequal = "ne"
		
		/// The branch is taken if the first value is less than the second value.
		case less = "lt"
		
		/// The branch is taken if the first value is greater than or equal to the second value.
		case lessOrEqual = "le"
		
		/// The branch is taken if the first value is less than the second value.
		case greater = "gt"
		
		/// The branch is taken if the first value is greater than or equal to the second value.
		case greaterOrEqual = "ge"
		
		/// Returns a relation *R* such that *x* *R* *y* iff ¬(*x* `self` *y*).
		public var negated: Self {
			switch self {
				case .equal:			return .unequal
				case .unequal:			return .equal
				case .less:				return .greaterOrEqual
				case .lessOrEqual:		return .greater
				case .greater:			return .lessOrEqual
				case .greaterOrEqual:	return .less
			}
		}
		
		/// Returns a function that determines whether `self` holds over two given integers.
		public var holds: (Int, Int) -> Bool {
			switch self {
				case .equal:			return (==)
				case .unequal:			return (!=)
				case .less:				return (<)
				case .lessOrEqual:		return (<=)
				case .greater:			return (>)
				case .greaterOrEqual:	return (>=)
			}
		}
		
		/// Returns a Boolean value indicating whether `self` holds when given two integers that are the same.
		public var reflexive: Bool {
			switch self {
				case .equal, .lessOrEqual, .greaterOrEqual:	return true
				case .unequal, .less, .greater:				return false
			}
		}
		
	}
	
}
