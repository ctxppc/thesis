// Glyco © 2021–2022 Constantino Tsarouhas

extension RV {
	
	/// A CHERI-RISC-V assembler statement.
	public enum Statement : Codable, Equatable, SimplyLowerable {
		
		/// A machine instruction or pseudo-instruction.
		case instruction(Instruction)
		
		/// A region of memory occupied by sufficient space to ensure subsequent statements are lowered in `byteAlignment`-byte-aligned memory.
		case padding(byteAlignment: Int)
		
		/// A region of memory filled with `count` copies of the `datumByteSize`-byte datum with value `value`.
		case data(value: Int, datumByteSize: Int, count: Int)
		
		/// A statement beginning the BSS section.
		///
		/// The section is readable, writeable, and nonexecutable. It does not occupy space in the ELF file but is allocated memory at runtime; data in it therefore can only be initialised at runtime.
		case bssSection
		
		/// A region of memory described by given statement and associated with a label.
		indirect case labelled(Label, Statement)
		
		// See protocol.
		func lowered(in context: inout Context) -> String {
			let tabs = String((0..<context.tabIndentation).map { _ in "\t" })
			switch self {
				
				case .instruction(let instruction):
				return "\(tabs)\(instruction.lowered(in: &context))"
				
				case .padding(byteAlignment: let byteAlignment):
				return "\(tabs).align \(byteAlignment)"
				
				case .data(value: let value, datumByteSize: 4, count: 1):
				return "\(tabs).dword \(value)"
				
				case .data(value: let value, datumByteSize: 16, count: 1):
				return "\(tabs).octa \(value)"
				
				case .data(value: let value, datumByteSize: let datumByteSize, count: let count):
				return "\(tabs).fill \(count), \(datumByteSize), \(value)"
				
				case .bssSection:
				return "\(tabs).bss"
				
				case .labelled(let label, .labelled(let innerLabel, let statement)):
				let next = Self.labelled(innerLabel, statement).lowered(in: &context)
				return "\(label.rawValue):\n\(next)"
				
				case .labelled(let label, let statement):
				let prefix = "\(label.rawValue):"
				let spacingWidth = (context.tabIndentation - prefix.count / 4).capped(to: 1...)
				let spacing = String((0..<spacingWidth).map { _ in "\t" })
				let next: String = {
					let previousIndentation = context.tabIndentation
					context.tabIndentation = 0
					defer { context.tabIndentation = previousIndentation }
					return statement.lowered(in: &context)
				}()
				return "\(prefix)\(spacing)\(next)"
				
			}
		}
	}
	
}

extension ArrayBuilder where Element == RV.Statement {
	static func buildExpression(_ statement: RV.Instruction) -> [RV.Statement] {
		[.instruction(statement)]
	}
}

func ~ (label: RV.Label, statement: RV.Statement) -> RV.Statement {
	.labelled(label, statement)
}

func ~ (label: RV.Label, instruction: RV.Instruction) -> RV.Statement {
	.labelled(label, .instruction(instruction))
}
