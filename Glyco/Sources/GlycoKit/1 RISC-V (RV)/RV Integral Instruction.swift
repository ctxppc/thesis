// Glyco © 2021 Constantino Tsarouhas

/// An RV32I instruction that performs an operation on integers.
enum RVIntegralInstruction : Codable {
	
	/// Performs *x* `operation` *y* and assigns the result to `rd`, where *x* is the value in `rs1` and *y* is the value in `rs2`.
	case registerRegister(operation: Operation, rd: RVRegister, rs1: RVRegister, rs2: RVRegister)
	
	/// Performs *x* `operation` `imm` and assigns the result to `rd`, where *x* is the value in `rs1`.
	case registerImmediate(operation: Operation, rd: RVRegister, rs1: RVRegister, imm: Int)
	
	/// An integral operation.
	enum Operation : String, Codable {
		case add, subtract = "sub"
		case and, or, xor
		case leftShift = "sll", zeroExtendingRightShift = "srl", msbExtendingRightShift = "sra"
	}
	
}

extension RVIntegralInstruction {
	
	/// The assembly representation of `self`.
	var assembly: String {
		switch self {
			
			case .registerRegister(operation: let operation, rd: let rd, rs1: let rs1, rs2: let rs2):
			return "\(operation) \(rd), \(rs1), \(rs2)"
			
			case .registerImmediate(operation: let operation, rd: let rd, rs1: let rs1, imm: let imm):
			return "\(operation)i \(rd), \(rs1), \(imm)"
			
		}
	}
	
}
