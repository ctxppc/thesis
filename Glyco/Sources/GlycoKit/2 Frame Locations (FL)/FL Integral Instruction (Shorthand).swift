// Glyco © 2021 Constantino Tsarouhas

infix operator <- : AssignmentPrecedence

func <- (rd: RVRegister, imm: Int) -> FLIntegralInstruction {
	.registerImmediate(operation: .add, rd: rd, rs1: .zero, imm: imm)
}

func <- (rd: RVRegister, rs: RVRegister) -> FLIntegralInstruction {
	.registerRegister(operation: .add, rd: rd, rs1: rs, rs2: .zero)
}

func <- (rd: RVRegister, binop: BinaryOperation) -> FLIntegralInstruction {
	.registerRegister(operation: binop.operation, rd: rd, rs1: binop.firstOperand, rs2: binop.secondOperand)
}

struct BinaryOperation {
	
	fileprivate init(firstOperand: RVRegister, operation: FLIntegralInstruction.Operation, secondOperand: RVRegister) {
		self.firstOperand = firstOperand
		self.operation = operation
		self.secondOperand = secondOperand
	}
	
	/// The first operand.
	let firstOperand: RVRegister
	
	/// The operation.
	let operation: FLIntegralInstruction.Operation
	
	/// The second operand.
	let secondOperand: RVRegister
	
}

func + (lhs: RVRegister, rhs: RVRegister) -> BinaryOperation {
	.init(firstOperand: lhs, operation: .add, secondOperand: rhs)
}

func - (lhs: RVRegister, rhs: RVRegister) -> BinaryOperation {
	.init(firstOperand: lhs, operation: .subtract, secondOperand: rhs)
}

func & (lhs: RVRegister, rhs: RVRegister) -> BinaryOperation {
	.init(firstOperand: lhs, operation: .and, secondOperand: rhs)
}

func | (lhs: RVRegister, rhs: RVRegister) -> BinaryOperation {
	.init(firstOperand: lhs, operation: .or, secondOperand: rhs)
}

func ^ (lhs: RVRegister, rhs: RVRegister) -> BinaryOperation {
	.init(firstOperand: lhs, operation: .xor, secondOperand: rhs)
}
