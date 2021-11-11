// Glyco © 2021 Constantino Tsarouhas

extension FO {
	
	/// An effect on an FO machine.
	///
	/// As a convention, the following verbiage is used in the context of data movement:
	/// * a datum is *retrieved from* a source or location;
	/// * a datum is *put in* a location;
	/// * a datum is *copied from* a source or location *to* a location.
	public enum Effect : Codable, Equatable, MultiplyLowerable {
		
		/// An effect that copies the datum from `source` to `destination`.
		case copy(destination: Location, source: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `destination`.
		case compute(destination: Location, lhs: Source, operation: BinaryOperator, rhs: Source)
		
		/// An effect that jumps to `target` if *x* `relation` *y*, where *x* is the value of `lhs` and *y* is the value of `rhs`.
		case branch(target: Label, lhs: Source, relation: BranchRelation, rhs: Source)
		
		/// An effect that jumps to `target`.
		case jump(target: Label)
		
		/// An effect that links the return address then jumps to `target`.
		case call(target: Label)
		
		/// An effect that jumps to the previously linked return address.
		case `return`
		
		/// An effect that can jumped to using given label.
		indirect case labelled(Label, Effect)
		
		/// An effect that does nothing.
		public static var nop: Self { .compute(destination: .register(.zero), lhs: .location(.register(.zero)), operation: .add, rhs: .location(.register(.zero))) }
		
		// See protocol.
		public func lowered(in context: inout ()) -> [Lower.Instruction] {
			
			/// Loads the datum in `source` in `temporaryRegister` if `source` isn't a register.
			///
			/// - Returns: A pair consisting of the instructions to perform before the main effect, and the register where the loaded datum is located.
			func prepare(source: Source, using temporaryRegister: Lower.Register) -> ([Lower.Instruction], Lower.Register) {
				switch source {
					case .immediate(let imm):			return ([temporaryRegister <- imm], temporaryRegister)
					case .location(.register(let r)):	return ([], r.lowered())
					case .location(.frameCell(let c)):	return ([temporaryRegister <- c], temporaryRegister)
				}
			}
			
			/// Stores the datum in `temporaryRegister` in `destination` if `destination` isn't a register.
			///
			/// - Returns: A pair consisting of the instructions to perform after the main effect, and the register wherein to put the result of the effect.
			func finalise(destination: Location, using temporaryRegister: Lower.Register) -> ([Lower.Instruction], Lower.Register) {
				switch destination {
					case .register(let r):	return ([], r.lowered())
					case .frameCell(let c):	return ([c <- temporaryRegister], temporaryRegister)
				}
			}
			
			switch self {
				
				case .copy(destination: .register(let dest), source: .immediate(let imm)):
				return [dest.lowered() <- imm]
				
				case .copy(destination: .register(let dest), source: .location(.register(let src))):
				return [dest.lowered() <- src.lowered()]
				
				case .copy(destination: .register(let dest), source: .location(.frameCell(let src))):
				return [dest.lowered() <- src]
				
				case .copy(destination: .frameCell(let dest), source: .immediate(let imm)):
				return [.t1 <- imm, dest <- .t1]
				
				case .copy(destination: .frameCell(let dest), source: .location(.register(let src))):
				return [dest <- src.lowered()]
				
				case .copy(destination: .frameCell(let dest), source: .location(.frameCell(let src))):
				return [.t1 <- src, dest <- .t1]
				
				case .compute(destination: let dest, lhs: let lhs, operation: let operation, rhs: .immediate(let rhs)):
				let (lhsPrep, lhsReg) = prepare(source: lhs, using: .t1)
				let (resFinalise, resReg) = finalise(destination: dest, using: .t2)
				return lhsPrep + [resReg <- FL.BinaryExpression.registerImmediate(rs1: lhsReg, operation: operation, imm: rhs)] + resFinalise
				
				case .compute(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs):
				let (lhsPrep, lhsReg) = prepare(source: lhs, using: .t1)
				let (rhsPrep, rhsReg) = prepare(source: rhs, using: .t2)
				let (resFinalise, resReg) = finalise(destination: destination, using: .t3)
				return lhsPrep
					+ rhsPrep
					+ [resReg <- .registerRegister(rs1: lhsReg, operation: operation, rs2: rhsReg)]
					+ resFinalise
				
				case .branch(target: let target, lhs: let lhs, relation: let relation, rhs: let rhs):
				let (lhsPrep, lhsReg) = prepare(source: lhs, using: .t1)
				let (rhsPrep, rhsReg) = prepare(source: rhs, using: .t2)
				return lhsPrep + rhsPrep + [.branch(target: target, rs1: lhsReg, relation: relation, rs2: rhsReg)]
				
				case .jump(target: let target):
				return [.jump(target: target)]
				
				case .call(target: let label):
				return [.call(target: label)]
				
				case .return:
				return [.return]
				
				case .labelled(let label, let effect):
				guard let (first, tail) = effect.lowered().splittingFirst() else { return [.labelled(label, .nop)] }
				return [.labelled(label, first)].appending(contentsOf: tail)
				
			}
		
		}
	
	}
	
	/// An integral operation.
	public typealias BinaryOperator = Lower.BinaryOperator
	
	public typealias Label = Lower.Label
	public typealias BranchRelation = Lower.BranchRelation
	
}
