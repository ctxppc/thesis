// Glyco © 2021–2022 Constantino Tsarouhas

//sourcery: longname = CHERI-RISC-V
//sourcery: description = "A language that maps directly to CHERI-RISC-V assembly statements, i.e., labels, instructions, and directives."
public enum RV : Language {
	
	/// A program in the RV language.
	public struct Program : Codable, GlycoKit.Program {
		
		/// Creates a program with given statements.
		public init(_ statements: [Statement]) {
			self.statements = statements
		}
		
		/// The program's statements.
		public var statements: [Statement]
		
		// See protocol.
		public func optimise(configuration: CompilationConfiguration) -> Bool { false }
		
		// See protocol.
		public func validate(configuration: CompilationConfiguration) {}
		
		// See protocol.
		public func lowered(configuration: CompilationConfiguration) throws -> Lower.Program {
			var context = Context(tabIndentation: 4)
			switch configuration.target {
				
				case .cheriBSD:
				return .init(rawValue: """
								.text
								
								.attribute	4, 16
								.attribute	5, "rv64i2p0_xcheri0p0"
								.file		"<unknown>.gly"
								
								.globl		main
								.p2align	1
								.type		main, @function
				main:			.cfi_startproc
								ccall		\(Label.runtime.rawValue)
								cret
				main.end:		.size		main, main.end-main
								.cfi_endproc
								
				\(try statements.lowered(in: &context).joined(separator: "\n"))
								
								.ident		"glyco version 0.1"
								.section	".note.GNU-stack", "", @progbits
								.addrsig
				""")
				
				case .sail:
				return .init(rawValue: """
								.text
								
								.global _start
				_start:			li t0, 1
								cspecialrw ct1, pcc, c0
								csetflags ct1, ct1, t0
								cincoffsetimm ct1, ct1, 16
								jr.cap ct1
								cllc ct0, _trap_vector
								cspecialrw c0, mtcc, ct0
								cllc ct0, rv.begin
								cspecialrw c0, mepcc, ct0
								mret
								
								.align 4
				_trap_vector:	li gp, 3
								j _exit
								
				_exit:			li t5, 1
								cllc ct0, tohost
								csw t5, 0(ct0)
								j _exit
								
				rv.begin:		ccall \(Label.runtime.rawValue)
								li gp, 1
								j _exit
								
				\(try statements.lowered(in: &context).joined(separator: "\n"))
								
								.data
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
