// Glyco © 2021–2022 Constantino Tsarouhas

public protocol Optimisable {
	
	/// Optimises `self` and returns a Boolean value indicating whether any changes have been made.
	@discardableResult
	mutating func optimise() throws -> Bool
	
}

extension Optimisable {
	
	/// Optimises `self` until it cannot be optimised more.
	mutating func optimiseUntilFixedPoint() throws {
		while try optimise() {}
	}
	
}

extension MutableCollection where Element : Optimisable {
	
	/// Optimises the elements in `self` and returns a Boolean value indicating whether any changes have been made.
	@discardableResult
	mutating func optimise() throws -> Bool {
		var optimised = false
		for index in indices {
			if try self[index].optimise() {
				optimised = true
			}
		}
		return optimised
	}
	
	/// Optimises the elements in `self` until they cannot be optimised more.
	mutating func optimiseUntilFixedPoint() throws {
		while try optimise() {}
	}
	
}
