// Glyco © 2021 Constantino Tsarouhas

public enum RV : Language {
	
	/// A program in the RV language.
	public struct Program : Codable, GlycoKit.Program {
		
		/// The program's instructions.
		public var instructions: [Instruction] = []
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) -> Lower.Program {
			switch configuration.target {
				
				case .cheriBSD:
				return .init(body: """
								.text
								
								.attribute	4, 16
								.attribute	5, "rv64i2p0_xcheri0p0"
								.file		"<unknown>.gly"
								
								.globl		main
								.p2align	1
								.type		main, @function
				main:			.cfi_startproc
								\(instructions
									.map { $0.compiled() }
									.joined(separator: "\n\t\t\t\t"))
				main.end:		.size		main, main.end-main
								.cfi_endproc
								
								.ident		"glyco version 0.1"
								.section	".note.GNU-stack", "", @progbits
								.addrsig
				""")
				
				case .sail:
				return .init(body: """
							.text
							
							.align		4
							.globl		main
							.type		main, @function
				main:		ccall		body
							ecall
				main.end:	.size		main, main.end-main
							
							.align		4
							.globl		body
							.type		body, @function
				body:		\(instructions
								.map { $0.compiled() }
								.joined(separator: "\n\t\t\t"))
				body.end:	.size		body, body.end-body
							
							.section	.tohost, "aw", @progbits
							
							.align		6
							.global		tohost
				tohost:		.dword		0
							
							.align		6
							.global		fromhost
				fromhost:	.dword		0
				""")
				
			}
		}
		
	}
	
	// See protocol.
	public typealias Lower = S
	
}
