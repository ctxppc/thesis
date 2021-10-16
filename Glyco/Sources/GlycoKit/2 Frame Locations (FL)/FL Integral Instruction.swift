// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	/// An FL instruction that performs an operation on integers.
	public enum IntegralInstruction : Codable {
		
		/// Performs *x* `operation` *y* and assigns the result to `rd`, where *x* is the value in `rs1` and *y* is the value in `rs2`.
		case registerRegister(operation: Operation, rd: RV.Register, rs1: RV.Register, rs2: RV.Register)
		
		/// Performs *x* `operation` `imm` and assigns the result to `rd`, where *x* is the value in `rs1`.
		case registerImmediate(operation: Operation, rd: RV.Register, rs1: RV.Register, imm: Int)
		
		/// An integral operation.
		public typealias Operation = RV.IntegralInstruction.Operation
		
	}
	
}

extension FL.IntegralInstruction {
	
	/// The RV representation of `self`.
	public var rvInstruction: RV.IntegralInstruction {
		switch self {
			
			case .registerRegister(operation: let operation, rd: let rd, rs1: let rs1, rs2: let rs2):
			return .registerRegister(operation: operation, rd: rd, rs1: rs1, rs2: rs2)
			
			case .registerImmediate(operation: let operation, rd: let rd, rs1: let rs1, imm: let imm):
			return .registerImmediate(operation: operation, rd: rd, rs1: rs1, imm: imm)
			
		}
	}
	
}

infix operator <- : AssignmentPrecedence

public func <- (rd: RV.Register, imm: Int) -> FL.IntegralInstruction {
	.registerImmediate(operation: .add, rd: rd, rs1: .zero, imm: imm)
}

public func <- (rd: RV.Register, rs: RV.Register) -> FL.IntegralInstruction {
	.registerRegister(operation: .add, rd: rd, rs1: rs, rs2: .zero)
}

public func <- (rd: RV.Register, binop: FL.BinaryOperation) -> FL.IntegralInstruction {
	.registerRegister(operation: binop.operation, rd: rd, rs1: binop.firstOperand, rs2: binop.secondOperand)
}
