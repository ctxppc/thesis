// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

protocol SimplyLowerable {
	
	/// A representation of `self` in a lower language.
	associatedtype Lowered
	
	/// A contextual value used during lowering.
	associatedtype Context = ()
	
	/// Returns a representation of `self` in a lower language.
	///
	/// - Parameter context: The context in which `self` is being lowered.
	///
	/// - Returns: A representation of `self` in a lower language.
	func lowered(in context: inout Context) throws -> Lowered
	
}

extension SimplyLowerable where Context == () {
	
	/// Returns a representation of `self` in a lower language.
	///
	/// - Returns: A representation of `self` in a lower language.
	func lowered() throws -> Lowered {
		var context: () = ()
		return try lowered(in: &context)
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
	func lowered(in context: inout Context) throws -> LoweredElements
	
}

extension MultiplyLowerable where Context == () {
	
	/// Returns a representation of `self` in a lower language.
	///
	/// - Returns: A representation of `self` in a lower language.
	func lowered() throws -> LoweredElements {
		var context: () = ()
		return try lowered(in: &context)
	}
	
}

extension Sequence where Element : SimplyLowerable {
	func lowered(in context: inout Element.Context) throws -> [Element.Lowered] {
		try self.map { try $0.lowered(in: &context) }
	}
}

extension Sequence where Element : SimplyLowerable, Element.Context == () {
	func lowered() throws -> [Element.Lowered] {
		try self.map { try $0.lowered() }
	}
}

extension Sequence where Element : MultiplyLowerable {
	func lowered(in context: inout Element.Context) throws -> [Element.LoweredElements.Element] {
		try self.flatMap { try $0.lowered(in: &context) }
	}
}

extension Sequence where Element : MultiplyLowerable, Element.Context == () {
	func lowered() throws -> [Element.LoweredElements.Element] {
		try self.flatMap { try $0.lowered() }
	}
}
