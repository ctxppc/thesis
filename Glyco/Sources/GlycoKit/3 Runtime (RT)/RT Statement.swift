// Glyco © 2021–2022 Constantino Tsarouhas

extension RT {
	public enum Statement : Codable, Equatable, MultiplyLowerable {
		
		/// A machine effect.
		case effect(Effect)
		
		/// A region of memory occupied by sufficient space to ensure the next statement is lowered in `byteAlignment`-byte-aligned memory.
		///
		/// The default alignment is 4 bytes, which is appropriate for (uncompressed) CHERI-RISC-V instructions.
		case padding(byteAlignment: Int = 4)
		
		/// A region of memory filled with `copies` copies of the `datumByteSize`-byte datum with value `value`.
		case filled(value: Int, datumByteSize: Int, copies: Int)
		
		/// A region of memory consisting of given signed word.
		case signedWord(Int)
		
		/// A region of memory consisting of a null capability.
		case nullCapability
		
		/// A statement beginning the BSS section.
		///
		/// The section is readable, writeable, and nonexecutable. It does not occupy space in the ELF file but is allocated memory at runtime; data in it therefore can only be initialised at runtime.
		case bssSection
		
		/// A region of memory described by given statement and associated with a label.
		indirect case labelled(Label, Statement)
		
		// See protocol.
		@ArrayBuilder<Lower.Statement>
		func lowered(in context: inout ()) throws -> [Lower.Statement] {
			switch self {
				
				case .effect(let effect):
				try effect.lowered().map { .effect($0) }
				
				case .padding(byteAlignment: let byteAlignment):
				Lower.Statement.padding(byteAlignment: byteAlignment)
				
				case .filled(value: let value, datumByteSize: let datumByteSize, copies: let copies):
				Lower.Statement.filled(value: value, datumByteSize: datumByteSize, copies: copies)
				
				case .signedWord(let value):
				Lower.Statement.signedWord(value)
				
				case .nullCapability:
				Lower.Statement.nullCapability
				
				case .bssSection:
				Lower.Statement.bssSection
				
				case .labelled(let label, let statement):
				if let (first, tail) = try statement.lowered(in: &context).splittingFirst() {
					label ~ first
					tail
				}
				
			}
		}
		
	}
}

extension ArrayBuilder where Element == RT.Statement {
	static func buildExpression(_ effect: RT.Effect) -> [RT.Statement] {
		[.effect(effect)]
	}
}

func ~ (label: RT.Label, statement: RT.Statement) -> RT.Statement {
	.labelled(label, statement)
}

func ~ (label: RT.Label, effect: RT.Effect) -> RT.Statement {
	.labelled(label, .effect(effect))
}