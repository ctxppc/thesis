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
		
		/// An effect that pushes a buffer of `bytes` bytes to the call frame and puts a capability for that buffer in given location.
		case pushBuffer(bytes: Int, into: Location)
		
		/// An effect that pops the buffer referred by the capability from given source.
		///
		/// This effect must only be used with buffers allocated in the current call frame. For any two buffers *a* and *b* allocated in the current call frame, *b* must be deallocated exactly once before deallocating *a*. Deallocation is not required before popping the call frame; in that case, deallocation is automatic.
		case popBuffer(Source)
		
		/// An effect that retrieves the datum at offset `offset` in the buffer in `of` and puts it in `to`.
		case getElement(DataType, of: Location, offset: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the buffer in `of` at offset `offset`.
		case setElement(DataType, of: Location, offset: Source, to: Source)
		
		/// Pushes given frame to the call stack.
		///
		/// This effect must be executed exactly once before any effects accessing the call frame.
		case pushFrame(Frame)
		
		/// Pops a frame from the call stack.
		///
		/// This effect must be executed exactly once before any effects accessing the previous call frame.
		case popFrame
		
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
			func load(_ type: DataType, from source: Source, using temporaryRegister: Lower.Register) throws -> ([Lower.Effect], Lower.Register) {
				switch source {
					case .immediate(let imm):			return ([.compute(into: temporaryRegister, value: Lower.Register.zero + imm)], temporaryRegister)
					case .location(.register(let r)):	return ([], try r.lowered())
					case .location(.frameCell(let c)):	return ([.load(type, into: temporaryRegister, from: c)], temporaryRegister)
				}
			}
			
			/// Stores the datum in `temporaryRegister` in `destination` if `destination` isn't a register.
			///
			/// - Returns: A pair consisting of the instructions to perform after the main effect, and the register wherein to put the result of the effect.
			func store(_ type: DataType, to destination: Location, using temporaryRegister: Lower.Register) throws -> ([Lower.Effect], Lower.Register) {
				switch destination {
					case .register(let r):	return ([], try r.lowered())
					case .frameCell(let c):	return ([.store(type, into: c, from: temporaryRegister)], temporaryRegister)
				}
			}
			
			let temp1 = Lower.Register.t1
			let temp2 = Lower.Register.t2
			let temp3 = Lower.Register.t3
			
			switch self {
				
				case .set(.u8, .register(let dest), to: .immediate(let imm)):
				return try [.compute(into: dest.lowered(), value: Lower.Register.zero + .init(UInt8(truncatingIfNeeded: imm)))]
				
				case .set(.s32, .register(let dest), to: .immediate(let imm)):
				return try [.compute(into: dest.lowered(), value: Lower.Register.zero + imm)]
				
				case .set(.cap, .register, to: .immediate):
				throw LoweringError.settingCapabilityUsingImmediate
				
				case .set(let type, .register(let dest), to: .location(.register(let src))):
				return try [.copy(type, into: dest.lowered(), from: src.lowered())]
				
				case .set(let type, .register(let dest), to: .location(.frameCell(let src))):
				return try [.load(type, into: dest.lowered(), from: src)]
				
				case .set(.cap, .frameCell, to: .immediate):
				throw LoweringError.settingCapabilityUsingImmediate
				
				case .set(let type, .frameCell(let dest), to: .immediate(let imm)):
				return [
					.compute(into: temp1, value: .zero + imm),
					.store(type, into: dest, from: temp1),
				]
				
				case .set(let type, .frameCell(let dest), to: .location(.register(let src))):
				return try [.store(type, into: dest, from: src.lowered())]
				
				case .set(let type, .frameCell(let dest), to: .location(.frameCell(let src))):
				return [
					.load(type, into: temp1, from: src),
					.store(type, into: dest, from: temp1),
				]
				
				case .compute(let lhs, let operation, .immediate(let rhs), to: let destination):
				let (loadLHS, lhs) = try load(.s32, from: lhs, using: temp1)
				let (storeResult, dest) = try store(.s32, to: destination, using: temp2)
				return loadLHS + [.compute(into: dest, value: .registerImmediate(lhs, operation, rhs))] + storeResult
				
				case .compute(let lhs, let operation, let rhs, to: let destination):
				let (loadLHS, lhs) = try load(.s32, from: lhs, using: temp1)
				let (loadRHS, rhs) = try load(.s32, from: rhs, using: temp2)
				let (storeResult, dest) = try store(.s32, to: destination, using: temp3)
				return loadLHS + loadRHS + [.compute(into: dest, value: .registerRegister(lhs, operation, rhs))] + storeResult
				
				case .pushBuffer(bytes: let bytes, into: let buffer):
				let (storeBufferCap, bufferCap) = try store(.cap, to: buffer, using: temp1)
				return [.pushBuffer(bytes: bytes, into: bufferCap)] + storeBufferCap
				
				case .popBuffer(let buffer):
				let (loadBufferCap, bufferCap) = try load(.cap, from: buffer, using: temp1)
				return loadBufferCap + [.popBuffer(bufferCap)]
				
				case .getElement(let type, of: let buffer, offset: let offset, to: let destination):
				let (loadBuffer, buffer) = try load(type, from: .location(buffer), using: temp1)
				let (loadOffset, offset) = try load(type, from: offset, using: temp2)
				let (storeElement, dest) = try store(type, to: destination, using: temp3)
				return loadBuffer + loadOffset + [.loadElement(type, into: dest, buffer: buffer, offset: offset)] + storeElement
				
				case .setElement(let type, of: let vector, offset: let offset, to: let element):
				let (loadBuffer, buffer) = try load(type, from: .location(vector), using: temp1)
				let (loadOffset, offset) = try load(type, from: offset, using: temp2)
				let (loadElement, element) = try load(type, from: element, using: temp3)
				return loadBuffer + loadOffset + loadElement + [.storeElement(type, buffer: buffer, offset: offset, from: element)]
				
				case .pushFrame(let frame):
				return [.pushFrame(frame)]
				
				case .popFrame:
				return [.popFrame]
				
				case .branch(to: let target, let lhs, let relation, let rhs):
				let (loadLHS, lhs) = try load(.s32, from: lhs, using: temp1)
				let (loadRHS, rhs) = try load(.s32, from: rhs, using: temp2)
				return loadLHS + loadRHS + [.branch(to: target, lhs, relation, rhs)]
				
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
