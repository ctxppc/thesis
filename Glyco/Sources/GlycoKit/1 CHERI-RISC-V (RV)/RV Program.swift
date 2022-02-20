// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = CHERI-RISC-V
//sourcery: description = A language that maps directly to CHERI-RISC-V (pseudo-)instructions.
public enum RV : Language {
	
	/// A program in the RV language.
	public struct Program : Codable, GlycoKit.Program {
		
		/// Creates a program with given instructions.
		public init(_ instructions: [Instruction]) {
			self.instructions = instructions
		}
		
		/// The program's instructions.
		public var instructions: [Instruction]
		
		// See protocol.
		public func optimise() -> Bool { false }
		
		// See protocol.
		public func validate() {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = Context(tabIndentation: 4)
			switch configuration.target {
				
				case .cheriBSD:
				return .init(assembly: """
								.text
								
								.attribute	4, 16
								.attribute	5, "rv64i2p0_xcheri0p0"
								.file		"<unknown>.gly"
								
								.globl		main
								.p2align	1
								.type		main, @function
				main:			.cfi_startproc
								ccall		rv.main
								cret
				main.end:		.size		main, main.end-main
								.cfi_endproc
								
				\(try instructions.lowered(in: &context).joined(separator: "\n"))
								
								.ident		"glyco version 0.1"
								.section	".note.GNU-stack", "", @progbits
								.addrsig
				""")
				
				case .sail:
				return .init(assembly: """
								.text
								
								.globl _start
				_start:			la t0, _trap_vector
								csrw mtvec, t0
								la t0, main
								csrw mepc, t0
								mret
								
								.align 4
				_trap_vector:	li gp, 3
								j _exit
								
				_exit:			auipc t5, 0x1
								sw gp, tohost, t5
								j _exit
								
				main:			la ra, rv.main
								jalr ra, ra
								li gp, 1
								j _exit
								
				\(try instructions.lowered(in: &context).joined(separator: "\n"))
								
								.align 6
								.global tohost
				tohost:			.dword 0
				""")
				
			}
		}
		
	}
	
	// See protocol.
	public typealias Lower = S
	
}
