// Glyco © 2021–2022 Constantino Tsarouhas

extension MM {
	
	public enum BinaryExpression : Codable, Equatable {
		
		/// Performs *x* `operation` *y* where *x* is the value in `rs1` and *y* is the value in `rs2`.
		case registerRegister(Register, BinaryOperator, Register)
		
		/// Performs *x* `operation` `imm` where *x* is the value in `rs1`.
		case registerImmediate(Register, BinaryOperator, Int)
		
	}
	
}

public func + (lhs: MM.Register, rhs: MM.Register) -> MM.BinaryExpression {
	.registerRegister(lhs, .add, rhs)
}

public func + (lhs: MM.Register, rhs: Int) -> MM.BinaryExpression {
	.registerImmediate(lhs, .add, rhs)
}

public func - (lhs: MM.Register, rhs: MM.Register) -> MM.BinaryExpression {
	.registerRegister(lhs, .sub, rhs)
}

public func - (lhs: MM.Register, rhs: Int) -> MM.BinaryExpression {
	.registerImmediate(lhs, .sub, rhs)
}

public func & (lhs: MM.Register, rhs: MM.Register) -> MM.BinaryExpression {
	.registerRegister(lhs, .and, rhs)
}

public func & (lhs: MM.Register, rhs: Int) -> MM.BinaryExpression {
	.registerImmediate(lhs, .and, rhs)
}

public func | (lhs: MM.Register, rhs: MM.Register) -> MM.BinaryExpression {
	.registerRegister(lhs, .or, rhs)
}

public func | (lhs: MM.Register, rhs: Int) -> MM.BinaryExpression {
	.registerImmediate(lhs, .or, rhs)
}

public func ^ (lhs: MM.Register, rhs: MM.Register) -> MM.BinaryExpression {
	.registerRegister(lhs, .xor, rhs)
}

public func ^ (lhs: MM.Register, rhs: Int) -> MM.BinaryExpression {
	.registerImmediate(lhs, .xor, rhs)
}
