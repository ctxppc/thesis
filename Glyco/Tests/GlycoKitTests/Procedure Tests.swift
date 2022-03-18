// Glyco © 2021–2022 Constantino Tsarouhas

@testable import GlycoKit
import XCTest

final class ProcedureTests : XCTestCase {
	
	func testSimpleInvoke() throws {
		
		let fortyTwo: EX.Label = "fortytwo"
		let source = EX.Program(
			.evaluate(fortyTwo, []),
			functions:	[
				.init(fortyTwo, takes: [], returns: .s32, in: .value(.constant(42)))
			]
		)
		
		let configuration = CompilationConfiguration(target: .sail, callingConvention: .conventional)
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
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
		
		let expected = """
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
						
		_exit:			auipcc ct5, 0x1
						cllc ct0, tohost
						cincoffset ct0, ct0, gp
						csc ct5, 0(ct0)
						j _exit
						
		rv.begin:		ccall rv.runtime
						li gp, 1
						j _exit
						
						.align 4
		rv.runtime:		cllc ct0, mm.heap
						cllc ct1, mm.heap.end
						csub t1, ct1, ct0
						csetbounds ct0, ct0, t1
						addi t1, zero, 7
						candperm ct0, ct0, t1
						cllc ct1, mm.heap.cap
						csc ct0, 0(ct1)
						cllc csp, mm.stack.low
						cllc ct0, mm.stack.high
						csub t1, ct0, csp
						csetbounds csp, csp, t1
						cgetaddr t0, ct0
						csetaddr csp, csp, t0
						addi t0, zero, 7
						candperm csp, csp, t0
						cllc ct0, mm.alloc
						cllc ct1, mm.alloc.end
						csub t1, ct1, ct0
						csetbounds ct0, ct0, t1
						addi t1, zero, 5
						candperm ct0, ct0, t1
						csealentry ct0, ct0
						cllc ct1, mm.alloc.cap
						csc ct0, 0(ct1)
						cllc ct6, rv.main
						cllc ct0, mm.user.end
						csub t0, ct0, ct6
						csetbounds ct6, ct6, t0
						addi t0, zero, 11
						candperm ct6, ct6, t0
						cmove cfp, cnull
						cjalr cnull, ct6
						.align 4
		mm.alloc:		cllc ct2, mm.heap.cap
						clc ct3, 0(ct2)
						csetbounds ct0, ct3, t0
						cgetlen t3, ct0
						cincoffset ct3, ct3, t3
						csc ct3, 0(ct2)
						clear 0, 128
						clear 3, 16
						cjalr ct1, ct1
		mm.heap.cap:	.octa 0
		mm.alloc.end:	.align 4
		mm.user:
		mm.alloc.cap:	.octa 0
		mm.scall.cap:	.octa 0
						.align 4
		rv.main:		csc cfp, -8(csp)
						cincoffsetimm cfp, csp, -8
						cincoffsetimm csp, csp, -16
						csc cra, -8(cfp)
						cjal cra, fortytwo
		cd.ret:			mv ra, a0
						mv a0, ra
						clc cra, -8(cfp)
						cincoffsetimm csp, cfp, 8
						clc cfp, 0(cfp)
						cjalr cnull, cra
		fortytwo:		csc cfp, -8(csp)
						cincoffsetimm cfp, csp, -8
						cincoffsetimm csp, csp, -8
						cmove cs1, cs1
						cmove ca4, cs2
						cmove ca5, cs3
						cmove ca6, cs4
						cmove ca7, cs5
						cmove cs6, cs6
						cmove cs7, cs7
						cmove cs8, cs8
						cmove cs9, cs9
						cmove ca2, cs10
						cmove ca3, cs11
						cmove ca1, cra
						addi ra, zero, 42
						mv a0, ra
						cmove cs1, cs1
						cmove cs2, ca4
						cmove cs3, ca5
						cmove cs4, ca6
						cmove cs5, ca7
						cmove cs6, cs6
						cmove cs7, cs7
						cmove cs8, cs8
						cmove cs9, cs9
						cmove cs10, ca2
						cmove cs11, ca3
						cmove cra, ca1
						cincoffsetimm csp, cfp, 8
						clc cfp, 0(cfp)
						cjalr cnull, cra
		mm.user.end:	.align 4
						.bss
		mm.heap:		.fill 1048576, 1, 0
		mm.heap.end:	.align 4
		mm.stack.low:	.fill 1048576, 1, 0
		mm.stack.high:	.align 4
						
						.data
						.align 6
						.global tohost
		tohost:			.dword 0
		"""
		
		XCTAssertEqual(loweredProgram.assembly, expected)
		
	}
	
}
