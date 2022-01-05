// Glyco © 2021–2022 Constantino Tsarouhas

extension FO {
	
	/// An effect on an FO machine.
	///
	/// As a convention, the following verbiage is used in the context of data movement:
	/// * a datum is *retrieved from* a source or location;
	/// * a datum is *put in* a location;
	/// * a datum is *copied from* a source or location *to* a location.
	public enum Effect : Codable, Equatable, MultiplyLowerable {
		
		/// An effect that copies the datum from `from` to `to`.
		case copy(from: Source, to: Location)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
		/// An effect that jumps to `to` if *x* `relation` *y*, where *x* is the value of `lhs` and *y* is the value of `rhs`.
		case branch(to: Label, Source, BranchRelation, Source)
		
		/// An effect that jumps to `to`.
		case jump(to: Label)
		
		/// An effect that links the return address then jumps to `target`.
		case call(Label)
		
		/// An effect that jumps to the previously linked return address.
		case `return`
		
		/// An effect that can jumped to using given label.
		indirect case labelled(Label, Effect)
		
		/// An effect that does nothing.
		public static var nop: Self { .compute(.location(.register(.zero)), .add, .location(.register(.zero)), to: .register(.zero)) }
		
		// See protocol.
		public func lowered(in context: inout ()) throws -> [Lower.Instruction] {
			
			/// Loads the datum in `source` in `temporaryRegister` if `source` isn't a register.
			///
			/// - Returns: A pair consisting of the instructions to perform before the main effect, and the register where the loaded datum is located.
			func prepare(source: Source, using temporaryRegister: Lower.Register) throws -> ([Lower.Instruction], Lower.Register) {
				switch source {
					case .immediate(let imm):			return ([temporaryRegister <- imm], temporaryRegister)
					case .location(.register(let r)):	return ([], try r.lowered())
					case .location(.frameCell(let c)):	return ([temporaryRegister <- c], temporaryRegister)
				}
			}
			
			/// Stores the datum in `temporaryRegister` in `destination` if `destination` isn't a register.
			///
			/// - Returns: A pair consisting of the instructions to perform after the main effect, and the register wherein to put the result of the effect.
			func finalise(destination: Location, using temporaryRegister: Lower.Register) throws -> ([Lower.Instruction], Lower.Register) {
				switch destination {
					case .register(let r):	return ([], try r.lowered())
					case .frameCell(let c):	return ([c <- temporaryRegister], temporaryRegister)
				}
			}
			
			switch self {
				
				case .copy(from: .immediate(let imm), to: .register(let dest)):
				return try [dest.lowered() <- imm]
				
				case .copy(from: .location(.register(let src)), to: .register(let dest)):
				return try [dest.lowered() <- src.lowered()]
				
				case .copy(from: .location(.frameCell(let src)), to: .register(let dest)):
				return try [dest.lowered() <- src]
				
				case .copy(from: .immediate(let imm), to: .frameCell(let dest)):
				return [.t1 <- imm, dest <- .t1]
				
				case .copy(from: .location(.register(let src)), to: .frameCell(let dest)):
				return try [dest <- src.lowered()]
				
				case .copy(from: .location(.frameCell(let src)), to: .frameCell(let dest)):
				return [.t1 <- src, dest <- .t1]
				
				case .compute(let lhs, let operation, .immediate(let rhs), to: let destination):
				let (lhsPrep, lhsReg) = try prepare(source: lhs, using: .t1)
				let (resFinalise, resReg) = try finalise(destination: destination, using: .t2)
				return lhsPrep + [resReg <- FL.BinaryExpression.registerImmediate(lhsReg, operation, rhs)] + resFinalise
				
				case .compute(let lhs, let operation, let rhs, to: let destination):
				let (lhsPrep, lhsReg) = try prepare(source: lhs, using: .t1)
				let (rhsPrep, rhsReg) = try prepare(source: rhs, using: .t2)
				let (resFinalise, resReg) = try finalise(destination: destination, using: .t3)
				return lhsPrep
					+ rhsPrep
					+ [resReg <- .registerRegister(lhsReg, operation, rhsReg)]
					+ resFinalise
				
				case .branch(to: let target, let lhs, let relation, let rhs):
				let (lhsPrep, lhsReg) = try prepare(source: lhs, using: .t1)
				let (rhsPrep, rhsReg) = try prepare(source: rhs, using: .t2)
				return lhsPrep + rhsPrep + [.branch(to: target, lhsReg, relation, rhsReg)]
				
				case .jump(to: let target):
				return [.jump(to: target)]
				
				case .call(let label):
				return [.call(label)]
				
				case .return:
				return [.return]
				
				case .labelled(let label, let effect):
				guard let (first, tail) = try effect.lowered().splittingFirst() else { return [.labelled(label, .nop)] }
				return [.labelled(label, first)].appending(contentsOf: tail)
				
			}
		
		}
	
	}
	
}
