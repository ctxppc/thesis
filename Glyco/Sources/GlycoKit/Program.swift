// Glyco © 2021 Constantino Tsarouhas

public protocol Program {
	
	/// Returns a representation of `self` in a lower language.
	func lowered() -> LowerProgram
	
	/// A program in the lower language.
	associatedtype LowerProgram : Program
	
	/// Compiles `self` to assembly.
	///
	/// This method must be implemented by languages that cannot be lowered. The default implementation lowers `self` and invokes `compiled()` on the lower language.
	func compiled() -> String
	
}

extension Program {
	public func compiled() -> String {
		lowered().compiled()
	}
}

extension Never : Program {
	public func lowered() -> Self {
		switch self {}
	}
}
