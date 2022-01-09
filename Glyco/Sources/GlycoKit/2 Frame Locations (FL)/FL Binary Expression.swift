// Glyco © 2021–2022 Constantino Tsarouhas

extension FL {
	
	public enum BinaryExpression : Codable, Equatable {
		
		/// Performs *x* `operation` *y* where *x* is the value in `rs1` and *y* is the value in `rs2`.
		case registerRegister(Register, BinaryOperator, Register)
		
		/// Performs *x* `operation` `imm` where *x* is the value in `rs1`.
		case registerImmediate(Register, BinaryOperator, Int)
		
	}
	
}

public func + (lhs: FL.Register, rhs: FL.Register) -> FL.BinaryExpression {
	.registerRegister(lhs, .add, rhs)
}

public func + (lhs: FL.Register, rhs: Int) -> FL.BinaryExpression {
	.registerImmediate(lhs, .add, rhs)
}

public func - (lhs: FL.Register, rhs: FL.Register) -> FL.BinaryExpression {
	.registerRegister(lhs, .sub, rhs)
}

public func - (lhs: FL.Register, rhs: Int) -> FL.BinaryExpression {
	.registerImmediate(lhs, .sub, rhs)
}

public func & (lhs: FL.Register, rhs: FL.Register) -> FL.BinaryExpression {
	.registerRegister(lhs, .and, rhs)
}

public func & (lhs: FL.Register, rhs: Int) -> FL.BinaryExpression {
	.registerImmediate(lhs, .and, rhs)
}

public func | (lhs: FL.Register, rhs: FL.Register) -> FL.BinaryExpression {
	.registerRegister(lhs, .or, rhs)
}

public func | (lhs: FL.Register, rhs: Int) -> FL.BinaryExpression {
	.registerImmediate(lhs, .or, rhs)
}

public func ^ (lhs: FL.Register, rhs: FL.Register) -> FL.BinaryExpression {
	.registerRegister(lhs, .xor, rhs)
}

public func ^ (lhs: FL.Register, rhs: Int) -> FL.BinaryExpression {
	.registerImmediate(lhs, .xor, rhs)
}
