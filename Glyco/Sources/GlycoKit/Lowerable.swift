// Glyco © 2021 Constantino Tsarouhas

import Foundation

protocol DirectlyLowerable {
	
	/// A representation of `self` in a lower language.
	associatedtype Lowered
	
	/// A contextual value used during lowering.
	associatedtype Context = ()
	
	/// Returns a representation of `self` in a lower language.
	///
	/// - Parameter context: The context in which `self` is being lowered.
	///
	/// - Returns: A representation of `self` in a lower language.
	func lowered(in context: inout Context) -> Lowered
	
}

extension DirectlyLowerable where Context == () {
	
	/// Returns a representation of `self` in a lower language.
	///
	/// - Returns: A representation of `self` in a lower language.
	func lowered() -> Lowered {
		var context: () = ()
		return lowered(in: &context)
	}
	
}

protocol MultiplyLowerable {
	
	/// A representation of `self` in a lower language.
	associatedtype LoweredElements : Sequence
	
	/// A contextual value used during lowering.
	associatedtype Context = ()
	
	/// Returns a representation of `self` in a lower language.
	///
	/// - Parameter context: The context in which `self` is being lowered.
	///
	/// - Returns: A representation of `self` in a lower language.
	func lowered(in context: inout Context) -> LoweredElements
	
}

extension MultiplyLowerable where Context == () {
	
	/// Returns a representation of `self` in a lower language.
	///
	/// - Returns: A representation of `self` in a lower language.
	func lowered() -> LoweredElements {
		var context: () = ()
		return lowered(in: &context)
	}
	
}

extension Sequence where Element : DirectlyLowerable {
	func lowered(in context: inout Element.Context) -> [Element.Lowered] {
		self.map { $0.lowered(in: &context) }
	}
}

extension Sequence where Element : DirectlyLowerable, Element.Context == () {
	func lowered() -> [Element.Lowered] {
		self.map { $0.lowered() }
	}
}

extension Sequence where Element : MultiplyLowerable {
	func lowered(in context: inout Element.Context) -> [Element.LoweredElements.Element] {
		self.flatMap { $0.lowered(in: &context) }
	}
}

extension Sequence where Element : MultiplyLowerable, Element.Context == () {
	func lowered() -> [Element.LoweredElements.Element] {
		self.flatMap { $0.lowered() }
	}
}
