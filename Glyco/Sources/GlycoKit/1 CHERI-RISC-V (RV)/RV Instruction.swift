// Glyco © 2021–2022 Constantino Tsarouhas

extension RV {
	
	/// A CHERI-RISC-V instruction.
	///
	/// Each instruction maps to exactly one assembly instruction.
	///
	/// As a convention, the following verbiage is used in the context of data movement:
	/// * a datum is *loaded from* or *stored in* memory;
	/// * a datum is *retrieved from* or *put in* a register; and
	/// * a datum is *copied from* a register *to* a register.
	public enum Instruction : Codable, Equatable, SimplyLowerable {
		
		/// An instruction that copies the datum from `source` to `destination`.
		case copy(DataType, destination: Register, source: Register)
		
		/// An instruction that performs *x* `operation` *y* and puts the result in `rd`, where *x* is the value in `rs1` and *y* is the value in `rs2`.
		case registerRegister(operation: BinaryOperator, rd: Register, rs1: Register, rs2: Register)
		
		/// An instruction that performs *x* `operation` `imm` and puts the result in `rd`, where *x* is the value in `rs1`.
		case registerImmediate(operation: BinaryOperator, rd: Register, rs1: Register, imm: Int)
		
		/// An instruction that loads the word of type `type` from memory at the address in `address`, with the address offset by `offset`.
		case loadWord(destination: Register, address: Register)
		
		/// An instruction that loads the capability of type `type` from memory at the address in `address`, with the address offset by `offset`, and puts it in `destination`.
		case loadCapability(destination: Register, address: Register, offset: Int)
		
		/// An instruction that retrieves the word of type `type` from `source` and stores it in memory at the address in `address`.
		case storeWord(source: Register, address: Register)
		
		/// An instruction that retrieves the capability of type `type` from `source` and stores it in memory at the address in `address`, with the address offset by `offset`.
		case storeCapability(source: Register, address: Register, offset: Int)
		
		/// An instruction that offsets the capability in `source` by the offset in `offset` and puts it in `destination`.
		case offsetCapability(destination: Register, source: Register, offset: Register)
		
		/// An instruction that offsets the capability in `source` by `offset` and puts it in `destination`.
		case offsetCapabilityWithImmediate(destination: Register, source: Register, offset: Int)
		
		/// An instruction that jumps to `target` if *x* `relation` *y*, where *x* is the value in `rs1` and *y* is the value in `rs2`.
		case branch(rs1: Register, relation: BranchRelation, rs2: Register, target: Label)
		
		/// An instruction that jumps to `target`.
		case jump(target: Label)
		
		/// An instruction that puts the next PCC in `cra`, then jumps to `target`.
		case call(target: Label)
		
		/// An instruction that jumps to address *x*, where *x* is the value in `cra`.
		case `return`
		
		/// An instruction that can be jumped to using given label.
		indirect case labelled(Label, Instruction)
		
		// See protocol.
		func lowered(in context: inout Context) -> String {
			let tabs = String((0..<context.tabIndentation).map { _ in "\t" })
			switch self {
				
				case .copy(.word, destination: let destination, source: let source):
				return "\(tabs)mv \(destination.x), \(source.x)"
				
				case .copy(.capability, destination: let destination, source: let source):
				return "\(tabs)cmove \(destination.c), \(source.c)"
				
				case .registerRegister(operation: let operation, rd: let rd, rs1: let rs1, rs2: let rs2):
				return "\(tabs)\(operation.rawValue) \(rd.x), \(rs1.x), \(rs2.x)"
				
				case .registerImmediate(operation: .sub, rd: let rd, rs1: let rs1, imm: let imm) where imm >= 0:
				return "\(tabs)addi \(rd.x), \(rs1.x), -\(imm)"
				
				case .registerImmediate(operation: .sub, rd: let rd, rs1: let rs1, imm: let imm):
				return "\(tabs)addi \(rd.x), \(rs1.x), \(imm)"
				
				case .registerImmediate(operation: let operation, rd: let rd, rs1: let rs1, imm: let imm):
				return "\(tabs)\(operation.rawValue)i \(rd.x), \(rs1.x), \(imm)"
				
				case .loadWord(destination: let rd, address: let address):
				return "\(tabs)lw.cap \(rd.x), 0(\(address.c))"
				
				case .loadCapability(destination: let cd, address: let address, offset: let offset):
				return "\(tabs)clc \(cd.x), \(offset)(\(address.c))"
				
				case .storeWord(source: let rs, address: let address):
				return "\(tabs)sw.cap \(rs.x), 0(\(address.c))"
				
				case .storeCapability(source: let cs, address: let address, offset: let offset):
				return "\(tabs)clc \(cs.x), \(offset)(\(address.c))"
				
				case .offsetCapability(destination: let destination, source: let source, offset: let offset):
				return "\(tabs)cincoffset \(destination.c), \(source.c), \(offset.x)"
				
				case .offsetCapabilityWithImmediate(destination: let destination, source: let source, offset: let offset):
				return "\(tabs)cincoffsetimm \(destination.c), \(source.c), \(offset)"
				
				case .branch(rs1: let rs1, relation: let relation, rs2: let rs2, target: let target):
				return "\(tabs)b\(relation.rawValue) \(rs1.x), \(rs2.x), \(target.rawValue)"
				
				case .jump(target: let target):
				return "\(tabs)j \(target.rawValue)"
				
				case .call(target: let target):
				return "\(tabs)ccall \(target.rawValue)"
				
				case .return:
				return "\(tabs)ret"
				
				case .labelled(let label, .labelled(let innerLabel, let instruction)):
				let next = Self.labelled(innerLabel, instruction).lowered(in: &context)
				return "\(label.rawValue):\n\(next)"
				
				case .labelled(let label, let instruction):
				let prefix = "\(label.rawValue):"
				let spacingWidth = (context.tabIndentation - prefix.count / 4).capped(to: 1...)
				let spacing = String((0..<spacingWidth).map { _ in "\t" })
				let next: String = {
					let previousIndentation = context.tabIndentation
					context.tabIndentation = 0
					defer { context.tabIndentation = previousIndentation }
					return instruction.lowered(in: &context)
				}()
				return "\(prefix)\(spacing)\(next)"
				
			}
		}
		
	}
	
}
