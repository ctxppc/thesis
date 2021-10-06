// Glyco © 2021 Constantino Tsarouhas

/// A CHERI-RISC-V instruction.
protocol Instruction {
	
	/// The assembly representation of `self`.
	var assembly: String { get }
	
}
