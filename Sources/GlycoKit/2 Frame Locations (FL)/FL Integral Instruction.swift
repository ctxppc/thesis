// Glyco © 2021 Constantino Tsarouhas

/// An FL instruction that performs an operation on integers.
enum FLIntegralInstruction : Codable {
	
	/// Performs *x* `operation` *y* and assigns the result to `rd`, where *x* is the value in `rs1` and *y* is the value in `rs2`.
	case registerRegister(operation: Operation, rd: RVRegister, rs1: RVRegister, rs2: RVRegister)
	
	/// Performs *x* `operation` `imm` and assigns the result to `rd`, where *x* is the value in `rs1`.
	case registerImmediate(operation: Operation, rd: RVRegister, rs1: RVRegister, imm: Int)
	
	/// An integral operation.
	typealias Operation = RVIntegralInstruction.Operation
	
}

extension FLIntegralInstruction {
	
	/// The RV representation of `self`.
	var rvInstruction: RVIntegralInstruction {
		switch self {
			
			case .registerRegister(operation: let operation, rd: let rd, rs1: let rs1, rs2: let rs2):
			return .registerRegister(operation: operation, rd: rd, rs1: rs1, rs2: rs2)
			
			case .registerImmediate(operation: let operation, rd: let rd, rs1: let rs1, imm: let imm):
			return .registerImmediate(operation: operation, rd: rd, rs1: rs1, imm: imm)
			
		}
	}
	
}
