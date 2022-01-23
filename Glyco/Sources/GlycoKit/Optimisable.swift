// Glyco © 2021–2022 Constantino Tsarouhas

protocol Optimisable {
	
	/// Optimises `self` and returns a Boolean value indicating whether any changes have been made.
	mutating func optimise() -> Bool
	
}
