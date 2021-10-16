// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	struct BinaryOperation {
		
		fileprivate init(firstOperand: RV.Register, operation: IntegralInstruction.Operation, secondOperand: RV.Register) {
			self.firstOperand = firstOperand
			self.operation = operation
			self.secondOperand = secondOperand
		}
		
		/// The first operand.
		let firstOperand: RV.Register
		
		/// The operation.
		let operation: IntegralInstruction.Operation
		
		/// The second operand.
		let secondOperand: RV.Register
		
	}
	
}

func + (lhs: RV.Register, rhs: RV.Register) -> FL.BinaryOperation {
	.init(firstOperand: lhs, operation: .add, secondOperand: rhs)
}

func - (lhs: RV.Register, rhs: RV.Register) -> FL.BinaryOperation {
	.init(firstOperand: lhs, operation: .subtract, secondOperand: rhs)
}

func & (lhs: RV.Register, rhs: RV.Register) -> FL.BinaryOperation {
	.init(firstOperand: lhs, operation: .and, secondOperand: rhs)
}

func | (lhs: RV.Register, rhs: RV.Register) -> FL.BinaryOperation {
	.init(firstOperand: lhs, operation: .or, secondOperand: rhs)
}

func ^ (lhs: RV.Register, rhs: RV.Register) -> FL.BinaryOperation {
	.init(firstOperand: lhs, operation: .xor, secondOperand: rhs)
}
