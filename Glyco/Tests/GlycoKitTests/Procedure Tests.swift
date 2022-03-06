// Glyco © 2021–2022 Constantino Tsarouhas

@testable import GlycoKit
import XCTest

final class ProcedureTests : XCTestCase {
	
	func testSimpleInvoke() throws {
		
		let fortyTwo = EX.Label(rawValue: "fortytwo")
		let source = EX.Program(
			.evaluate(fortyTwo, []),
			functions:	[
				.init(fortyTwo, takes: [], returns: .s32, in: .value(.constant(42)))
			]
		)
		
		let configuration = CompilationConfiguration(target: .sail)
		let loweredProgram = try source
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
		
		let expected = """
						.text
						
						.global _start
		_start:			cllc ct0, _trap_vector
						cspecialrw c0, mtcc, ct0
						cllc ct0, rv.begin
						cspecialrw c0, mepcc, ct0
						mret
						
						.align 4
		_trap_vector:	li gp, 3
						j _exit
						
		_exit:			auipcc ct5, 0x1
						cllc ct0, tohost
						cincoffset ct0, ct0, gp
						csc ct5, 0(ct0)
						j _exit
						
		rv.begin:		ccall rv.init
						ccall rv.main
						li gp, 1
						j _exit
						
						.align 4
		rv.init:		cllc ca0, mm.heap
						cllc ca1, mm.heap.end
						csub a2, ca1, ca0
						csetbounds ca0, ca0, a2
						addi a4, zero, 7
						candperm ca0, ca0, a4
						cllc ca3, mm.heap.cap
						sc.cap ca0, 0(ca3)
						cllc ca0, mm.alloc
						cllc ca1, mm.alloc.end
						csub a2, ca1, ca0
						csetbounds ca0, ca0, a2
						addi a4, zero, 5
						candperm ca0, ca0, a4
						csealentry ca0, ca0
						cllc ca3, mm.alloc.cap
						sc.cap ca0, 0(ca3)
						ret.cap
						.align 4
		mm.alloc:		cllc ca1, mm.heap.cap
						lc.cap ca2, 0(ca1)
						csetbounds ca0, ca2, a0
						cgetlen a3, ca0
						cincoffset ca2, ca2, a3
						sc.cap ca2, 0(ca1)
						ret.cap
		mm.heap.cap:	.quad 0
		mm.alloc.end:	.dword 0
		mm.user:
		mm.alloc.cap:	.quad 0
						.align 4
		rv.main:		cincoffsetimm ct0, csp, -8
						sc.cap cfp, 0(ct0)
						cmove cfp, ct0
						cincoffsetimm csp, csp, -8
						ccall fortytwo
		cd.ret:			mv s1, a0
						mv a0, s1
						cincoffsetimm csp, cfp, 8
						lc.cap cfp, 0(cfp)
						ret.cap
		fortytwo:		cincoffsetimm ct0, csp, -8
						sc.cap cfp, 0(ct0)
						cmove cfp, ct0
						cincoffsetimm csp, csp, -8
						addi s1, zero, 42
						mv a0, s1
						cincoffsetimm csp, cfp, 8
						lc.cap cfp, 0(cfp)
						ret.cap
		mm.user.end:	.dword 0
		mm.heap:		.fill 1048576, 1, 0
		mm.heap.end:	.dword 0
						
		rv.end:			.align 6
						.global tohost
		tohost:			.dword 0
		"""
		
		XCTAssertEqual(loweredProgram.assembly, expected)
		
	}
	
}
