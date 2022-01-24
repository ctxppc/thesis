// Glyco © 2021–2022 Constantino Tsarouhas

extension CF {
	
	public enum BinaryExpression : Codable, Equatable {
		
		/// Performs *x* `operation` *y* where *x* is the value in `rs1` and *y* is the value in `rs2`.
		case registerRegister(Register, BinaryOperator, Register)
		
		/// Performs *x* `operation` `imm` where *x* is the value in `rs1`.
		case registerImmediate(Register, BinaryOperator, Int)
		
	}
	
}

public func + (lhs: CF.Register, rhs: CF.Register) -> CF.BinaryExpression {
	.registerRegister(lhs, .add, rhs)
}

public func + (lhs: CF.Register, rhs: Int) -> CF.BinaryExpression {
	.registerImmediate(lhs, .add, rhs)
}

public func - (lhs: CF.Register, rhs: CF.Register) -> CF.BinaryExpression {
	.registerRegister(lhs, .sub, rhs)
}

public func - (lhs: CF.Register, rhs: Int) -> CF.BinaryExpression {
	.registerImmediate(lhs, .sub, rhs)
}

public func & (lhs: CF.Register, rhs: CF.Register) -> CF.BinaryExpression {
	.registerRegister(lhs, .and, rhs)
}

public func & (lhs: CF.Register, rhs: Int) -> CF.BinaryExpression {
	.registerImmediate(lhs, .and, rhs)
}

public func | (lhs: CF.Register, rhs: CF.Register) -> CF.BinaryExpression {
	.registerRegister(lhs, .or, rhs)
}

public func | (lhs: CF.Register, rhs: Int) -> CF.BinaryExpression {
	.registerImmediate(lhs, .or, rhs)
}

public func ^ (lhs: CF.Register, rhs: CF.Register) -> CF.BinaryExpression {
	.registerRegister(lhs, .xor, rhs)
}

public func ^ (lhs: CF.Register, rhs: Int) -> CF.BinaryExpression {
	.registerImmediate(lhs, .xor, rhs)
}
