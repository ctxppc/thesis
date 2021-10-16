// Glyco © 2021 Constantino Tsarouhas

extension FO {
	
	/// An effect on an FO machine.
	public enum Effect : Codable {
		
		/// Assigns the value at `source` to `destination`.
		case assign(destination: Location, source: Source)
		
		/// Assigns the result of `lhs` `operation` `rhs` to `destination`.
		case operation(destination: Location, lhs: Source, operation: BinaryIntegralOperation, rhs: Source)
		
		/// An integral operation.
		public typealias BinaryIntegralOperation = Lower.IntegralInstruction.Operation
		
		/// Returns a representation of `self` in a lower language.
		public func lowered() -> [Lower.Instruction] {
			
			/// Fetches the value in `source` in `temporaryRegister` if `source` isn't a register.
			///
			/// - Returns: A pair consisting of the instructions to perform before the main effect, and the register where the fetched datum is located.
			func prepare(source: Source, using temporaryRegister: Lower.Register) -> ([Lower.Instruction], Lower.Register) {
				switch source {
					case .immediate(let imm):			return ([.integral(temporaryRegister <- imm)], temporaryRegister)
					case .location(.register(let r)):	return ([], r)
					case .location(.frameCell(let c)):	return ([.load(temporaryRegister <- c)], temporaryRegister)
				}
			}
			
			/// Writes the value in `temporaryRegister` to `destination` if `destination` isn't a register.
			///
			/// - Returns: A pair consisting of the instructions to perform after the main effect, and the register whereon to write the result of the effect.
			func finalise(destination: Location, temporaryRegister: Lower.Register) -> ([Lower.Instruction], Lower.Register) {
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
				let (lhsPrep, lhsReg) = prepare(source: lhs, using: .t0)
				let (resFinalise, resReg) = finalise(destination: dest, temporaryRegister: .t2)
				return lhsPrep + [.integral(.registerImmediate(operation: operation, rd: resReg, rs1: lhsReg, imm: rhs))] + resFinalise
				
				case .operation(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs):
				let (lhsPrep, lhsReg) = prepare(source: lhs, using: .t0)
				let (rhsPrep, rhsReg) = prepare(source: rhs, using: .t1)
				let (resFinalise, resReg) = finalise(destination: destination, temporaryRegister: .t2)
				return lhsPrep
					+ rhsPrep
					+ [.integral(.registerRegister(operation: operation, rd: resReg, rs1: lhsReg, rs2: rhsReg))]
					+ resFinalise
				
			}
		
		}
	
	}
	
}
