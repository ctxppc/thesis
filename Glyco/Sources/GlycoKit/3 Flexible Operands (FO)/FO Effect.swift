// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension FO {
	
	/// An effect on an FO machine.
	///
	/// As a convention, the following verbiage is used in the context of data movement:
	/// * a datum is *retrieved from* a source or location;
	/// * a datum is *put in* a location;
	/// * a datum is *copied from* a source or location *to* a location.
	public enum Effect : Codable, Equatable, MultiplyLowerable {
		
		/// An effect that copies the datum from `from` to `to`.
		///
		/// When `to` is an immediate, the data type cannot be `.capability`.
		case set(DataType, Location, to: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
		/// An effect that pushes a vector of `count` elements to the call frame and puts a capability for that vector in `into`.
		case allocateVector(DataType, count: Int = 1, into: Location)
		
		/// An effect that retrieves the element at zero-based position `at` in the vector in `of` and puts it in `to`.
		case getElement(DataType, of: Location, at: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(DataType, of: Location, at: Source, to: Source)
		
		/// Pushes a frame of size `bytes` bytes to the call stack by copying `csp` to `cfp` then offsetting `csp` by `bytes` bytes downward.
		///
		/// This effect must be executed exactly once before any effects accessing the call frame.
		case pushFrame(bytes: Int)
		
		/// Pops a frame by copying `cfp` to `csp` then restoring `cfp` to the capability stored in `savedFrameCapability`.
		///
		/// This effect must be executed exactly once before any effects accessing the previous call frame.
		case popFrame(savedFrameCapability: Frame.Location)
		
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
		public func lowered(in context: inout ()) throws -> [Lower.Effect] {
			
			/// Loads the datum in `source` in `temporaryRegister` if `source` isn't a register.
			///
			/// - Returns: A pair consisting of the instructions to perform before the main effect, and the register where the loaded datum is located.
			func prepare(source: Source, using temporaryRegister: Lower.Register, type: DataType) throws -> ([Lower.Effect], Lower.Register) {
				switch source {
					case .immediate(let imm):			return ([.compute(into: temporaryRegister, value: Lower.Register.zero + imm)], temporaryRegister)
					case .location(.register(let r)):	return ([], try r.lowered())
					case .location(.frameCell(let c)):	return ([.load(type, into: temporaryRegister, from: c)], temporaryRegister)
				}
			}
			
			/// Stores the datum in `temporaryRegister` in `destination` if `destination` isn't a register.
			///
			/// - Returns: A pair consisting of the instructions to perform after the main effect, and the register wherein to put the result of the effect.
			func finalise(destination: Location, using temporaryRegister: Lower.Register, type: DataType) throws -> ([Lower.Effect], Lower.Register) {
				switch destination {
					case .register(let r):	return ([], try r.lowered())
					case .frameCell(let c):	return ([.store(type, into: c, from: temporaryRegister)], temporaryRegister)
				}
			}
			
			switch self {
				
				case .set(.word, .register(let dest), to: .immediate(let imm)):
				return try [.compute(into: dest.lowered(), value: Lower.Register.zero + imm)]
				
				case .set(.capability, .register, to: .immediate):
				throw LoweringError.settingCapabilityUsingImmediate
				
				case .set(let type, .register(let dest), to: .location(.register(let src))):
				return try [.copy(type, into: dest.lowered(), from: src.lowered())]
				
				case .set(let type, .register(let dest), to: .location(.frameCell(let src))):
				return try [.load(type, into: dest.lowered(), from: src)]
				
				case .set(.word, .frameCell(let dest), to: .immediate(let imm)):
				return [
					.compute(into: .t1, value: .zero + imm),
					.store(.word, into: dest, from: .t1)
				]
				
				case .set(.capability, .frameCell, to: .immediate):
				throw LoweringError.settingCapabilityUsingImmediate
				
				case .set(let type, .frameCell(let dest), to: .location(.register(let src))):
				return try [.store(type, into: dest, from: src.lowered())]
				
				case .set(let type, .frameCell(let dest), to: .location(.frameCell(let src))):
				return [.load(type, into: .t1, from: src), .store(type, into: dest, from: .t1)]
				
				case .compute(let lhs, let operation, .immediate(let rhs), to: let destination):
				let (lhsPrep, lhsReg) = try prepare(source: lhs, using: .t1, type: .word)
				let (resFinalise, resReg) = try finalise(destination: destination, using: .t2, type: .word)
				return lhsPrep + [.compute(into: resReg, value: .registerImmediate(lhsReg, operation, rhs))] + resFinalise
				
				case .compute(let lhs, let operation, let rhs, to: let destination):
				let (lhsPrep, lhsReg) = try prepare(source: lhs, using: .t1, type: .word)
				let (rhsPrep, rhsReg) = try prepare(source: rhs, using: .t2, type: .word)
				let (resFinalise, resReg) = try finalise(destination: destination, using: .t3, type: .word)
				return lhsPrep + rhsPrep + [.compute(into: resReg, value: .registerRegister(lhsReg, operation, rhsReg))] + resFinalise
				
				case .allocateVector(let type, count: let count, into: let vector):
				let (finaliseVector, vectorReg) = try finalise(destination: vector, using: .t1, type: type)
				return [.allocateVector(type, count: count, into: vectorReg)] + finaliseVector
				
				case .getElement(let type, of: let vector, at: let index, to: let destination):
				let (vecPrep, vecReg) = try prepare(source: .location(vector), using: .t1, type: type)
				let (idxPrep, idxReg) = try prepare(source: index, using: .t2, type: type)
				let (resFinalise, resReg) = try finalise(destination: destination, using: .t3, type: type)
				return vecPrep + idxPrep + [.loadElement(.word, into: resReg, vector: vecReg, index: idxReg)] + resFinalise
				
				case .setElement(let type, of: let vector, at: let index, to: let element):
				let (vecPrep, vecReg) = try prepare(source: .location(vector), using: .t1, type: type)
				let (idxPrep, idxReg) = try prepare(source: index, using: .t2, type: type)
				let (elemPrep, elemReg) = try prepare(source: element, using: .t3, type: type)
				return vecPrep + idxPrep + elemPrep + [.storeElement(.word, vector: vecReg, index: idxReg, from: elemReg)]
				
				case .pushFrame(bytes: let bytes):
				return [.pushFrame(bytes: bytes)]
				
				case .popFrame(savedFrameCapability: let savedFrameCapability):
				return [.popFrame(savedFrameCapability: savedFrameCapability)]
				
				case .branch(to: let target, let lhs, let relation, let rhs):
				let (lhsPrep, lhsReg) = try prepare(source: lhs, using: .t1, type: .word)
				let (rhsPrep, rhsReg) = try prepare(source: rhs, using: .t2, type: .word)
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
		
		enum LoweringError : LocalizedError {
			case settingCapabilityUsingImmediate
			var errorDescription: String? {
				switch self {
					case .settingCapabilityUsingImmediate:	return "Cannot set a capability register or frame cell using an immediate"
				}
			}
		}
		
	}
	
}
