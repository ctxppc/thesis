// Glyco © 2021 Constantino Tsarouhas

/// An effect on an FO machine.
enum FOEffect : Codable {
	
	/// Assigns the value at `source` to `destination`.
	case assign(destination: FLLocation, source: FOSource)
	
	/// Assigns the result of `lhs` `operation` `rhs` to `destination`.
	case operation(destination: FLLocation, lhs: FOSource, operation: BinaryIntegralOperation, rhs: FOSource)
	
	/// An integral operation.
	typealias BinaryIntegralOperation = FLIntegralInstruction.Operation
	
}

extension FOEffect {
	
	/// The FL representation of `self`.
	var flInstructions: [FLInstruction] {
		
		/// Fetches the value in `source` in `temporaryRegister` if `source` isn't a register.
		///
		/// - Returns: A pair consisting of the instructions to perform before the main effect, and the register where the fetched datum is located.
		func prepare(source: FOSource, temporaryRegister: RVRegister) -> ([FLInstruction], RVRegister) {
			switch source {
				case .immediate(let imm):			return ([.integral(temporaryRegister <- imm)], temporaryRegister)
				case .location(.register(let r)):	return ([], r)
				case .location(.frameCell(let c)):	return ([.load(temporaryRegister <- c)], temporaryRegister)
			}
		}
		
		/// Writes the value in `temporaryRegister` to `destination` if `destination` isn't a register.
		///
		/// - Returns: A pair consisting of the instructions to perform after the main effect, and the register whereon to write the result of the effect.
		func finalise(destination: FLLocation, temporaryRegister: RVRegister) -> ([FLInstruction], RVRegister) {
			switch destination {
				case .register(let r):	return ([], r)
				case .frameCell(let c):	return ([.store(c <- temporaryRegister)], temporaryRegister)
			}
		}
		
		switch self {
			
			case .assign(destination: .register(let dest), source: .immediate(let imm)):
			return [.integral(dest <- imm)]
			
			case .assign(destination: .register(let dest), source: .location(.register(let src))):
			return [.integral(dest <- src)]
			
			case .assign(destination: .register(let dest), source: .location(.frameCell(let src))):
			return [.load(dest <- src)]
			
			case .assign(destination: .frameCell(let dest), source: .immediate(let imm)):
			return [.integral(.t0 <- imm), .store(dest <- .t0)]
			
			case .assign(destination: .frameCell(let dest), source: .location(.register(let src))):
			return [.store(dest <- src)]
			
			case .assign(destination: .frameCell(let dest), source: .location(.frameCell(let src))):
			return [.load(.t0 <- src), .store(dest <- .t0)]
			
			case .operation(destination: let dest, lhs: let lhs, operation: let operation, rhs: .immediate(let rhs)):
			let (lhsPrep, lhsReg) = prepare(source: lhs, temporaryRegister: .t0)
			let (resFinalise, resReg) = finalise(destination: dest, temporaryRegister: .t2)
			return lhsPrep + [.integral(.registerImmediate(operation: operation, rd: resReg, rs1: lhsReg, imm: rhs))] + resFinalise
			
			case .operation(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs):
			let (lhsPrep, lhsReg) = prepare(source: lhs, temporaryRegister: .t0)
			let (rhsPrep, rhsReg) = prepare(source: rhs, temporaryRegister: .t1)
			let (resFinalise, resReg) = finalise(destination: destination, temporaryRegister: .t2)
			return lhsPrep
				+ rhsPrep
				+ [.integral(.registerRegister(operation: operation, rd: resReg, rs1: lhsReg, rs2: rhsReg))]
				+ resFinalise
			
		}
		
	}
	
}
