// Glyco © 2021–2022 Constantino Tsarouhas

extension RV {
	
	/// A relation between values that can be used to decide whether to take a branch.
	public enum BranchRelation : String, Element {
		
		/// The branch is taken if the values are equal.
		case eq
		
		/// The branch is taken if the values are not equal.
		case ne
		
		/// The branch is taken if the first value is less than the second value.
		case lt
		
		/// The branch is taken if the first value is greater than or equal to the second value.
		case le
		
		/// The branch is taken if the first value is less than the second value.
		case gt
		
		/// The branch is taken if the first value is greater than or equal to the second value.
		case ge
		
		/// Returns a relation *R* such that *x* *R* *y* iff ¬(*x* `self` *y*).
		public var negated: Self {
			switch self {
				case .eq:	return .ne
				case .ne:	return .eq
				case .lt:	return .ge
				case .le:	return .gt
				case .gt:	return .le
				case .ge:	return .lt
			}
		}
		
		/// Returns a function that determines whether `self` holds over two given integers.
		public var holds: (Int, Int) -> Bool {
			switch self {
				case .eq:	return (==)
				case .ne:	return (!=)
				case .lt:	return (<)
				case .le:	return (<=)
				case .gt:	return (>)
				case .ge:	return (>=)
			}
		}
		
		/// Returns a Boolean value indicating whether `self` holds when given two integers that are the same.
		public var reflexive: Bool {
			switch self {
				case .eq, .le, .ge:	return true
				case .ne, .lt, .gt:	return false
			}
		}
		
	}
	
}
