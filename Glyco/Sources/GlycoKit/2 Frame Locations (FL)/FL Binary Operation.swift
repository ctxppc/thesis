// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	public struct BinaryOperation {
		
		fileprivate init(firstOperand: RV.Register, operation: IntegralInstruction.Operation, secondOperand: RV.Register) {
			self.firstOperand = firstOperand
			self.operation = operation
			self.secondOperand = secondOperand
		}
		
		/// The first operand.
		public let firstOperand: RV.Register
		
		/// The operation.
		public let operation: IntegralInstruction.Operation
		
		/// The second operand.
		public let secondOperand: RV.Register
		
	}
	
}

public func + (lhs: RV.Register, rhs: RV.Register) -> FL.BinaryOperation {
	.init(firstOperand: lhs, operation: .add, secondOperand: rhs)
}

public func - (lhs: RV.Register, rhs: RV.Register) -> FL.BinaryOperation {
	.init(firstOperand: lhs, operation: .subtract, secondOperand: rhs)
}

public func & (lhs: RV.Register, rhs: RV.Register) -> FL.BinaryOperation {
	.init(firstOperand: lhs, operation: .and, secondOperand: rhs)
}

public func | (lhs: RV.Register, rhs: RV.Register) -> FL.BinaryOperation {
	.init(firstOperand: lhs, operation: .or, secondOperand: rhs)
}

public func ^ (lhs: RV.Register, rhs: RV.Register) -> FL.BinaryOperation {
	.init(firstOperand: lhs, operation: .xor, secondOperand: rhs)
}
