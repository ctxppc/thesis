// Glyco © 2021–2022 Constantino Tsarouhas

extension RV {
	
	/// An arithmetic operator over two registers.
	public enum BinaryOperator : String, Element {
		case add, sub
		case mul
		case and, or, xor
		case sll, srl, sra
	}
	
}
