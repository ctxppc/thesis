// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	public enum BinaryExpression : Codable {
		
		/// Performs *x* `operation` *y* where *x* is the value in `rs1` and *y* is the value in `rs2`.
		case registerRegister(rs1: Register, operation: Operation, rs2: Register)
		
		/// Performs *x* `operation` `imm` where *x* is the value in `rs1`.
		case registerImmediate(rs1: Register, operation: Operation, imm: Int)
		
		/// An operation between two operands.
		public typealias Operation = Lower.Instruction.BinaryOperation
		
	}
	
}

public func + (lhs: FL.Register, rhs: FL.Register) -> FL.BinaryExpression {
	.registerRegister(rs1: lhs, operation: .add, rs2: rhs)
}

public func + (lhs: FL.Register, rhs: Int) -> FL.BinaryExpression {
	.registerImmediate(rs1: lhs, operation: .add, imm: rhs)
}

public func - (lhs: FL.Register, rhs: FL.Register) -> FL.BinaryExpression {
	.registerRegister(rs1: lhs, operation: .subtract, rs2: rhs)
}

public func - (lhs: FL.Register, rhs: Int) -> FL.BinaryExpression {
	.registerImmediate(rs1: lhs, operation: .subtract, imm: rhs)
}

public func & (lhs: FL.Register, rhs: FL.Register) -> FL.BinaryExpression {
	.registerRegister(rs1: lhs, operation: .and, rs2: rhs)
}

public func & (lhs: FL.Register, rhs: Int) -> FL.BinaryExpression {
	.registerImmediate(rs1: lhs, operation: .and, imm: rhs)
}

public func | (lhs: FL.Register, rhs: FL.Register) -> FL.BinaryExpression {
	.registerRegister(rs1: lhs, operation: .or, rs2: rhs)
}

public func | (lhs: FL.Register, rhs: Int) -> FL.BinaryExpression {
	.registerImmediate(rs1: lhs, operation: .or, imm: rhs)
}

public func ^ (lhs: FL.Register, rhs: FL.Register) -> FL.BinaryExpression {
	.registerRegister(rs1: lhs, operation: .xor, rs2: rhs)
}

public func ^ (lhs: FL.Register, rhs: Int) -> FL.BinaryExpression {
	.registerImmediate(rs1: lhs, operation: .xor, imm: rhs)
}
