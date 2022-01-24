// Glyco © 2021–2022 Constantino Tsarouhas

protocol Optimisable {
	
	/// Optimises `self` and returns a Boolean value indicating whether any changes have been made.
	@discardableResult
	mutating func optimise() -> Bool
	
}

extension MutableCollection where Element : Optimisable {
	
	/// Optimises the elements in `self` and returns a Boolean value indicating whether any changes have been made.
	@discardableResult
	mutating func optimise() -> Bool {
		var optimised = false
		for index in indices {
			if self[index].optimise() {
				optimised = true
			}
		}
		return optimised
	}
	
}
