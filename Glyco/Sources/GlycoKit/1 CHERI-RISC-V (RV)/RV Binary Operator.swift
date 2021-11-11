// Glyco © 2021 Constantino Tsarouhas

extension RV {
	
	/// An arithmetic operator over two registers.
	public enum BinaryOperator : String, Equatable, Codable {
		case add, subtract = "sub"
		case and, or, xor
		case leftShift = "sll", zeroExtendingRightShift = "srl", msbExtendingRightShift = "sra"
	}
	
}
