// Glyco © 2021–2022 Constantino Tsarouhas

@testable import GlycoKit
import XCTest

final class ProcedureTests : XCTestCase {
	
	func testSimpleInvoke() throws {
		
		let fortyTwo: EX.Label = "fortytwo"
		let source = EX.Program(
			.evaluate(.function(fortyTwo), []),
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
						
		_exit:			li t5, 1
						cllc ct0, tohost
						csw t5, 0(ct0)
						j _exit
						
		rv.begin:		ccall rv.runtime
						li gp, 1
						j _exit
						
						.balign 4
		rv.runtime:		cllc ct0, mm.heap
						cllc ct1, mm.heap_end
						csub t1, ct1, ct0
						csetbounds ct0, ct0, t1
						addi t1, zero, 317
						candperm ct0, ct0, t1
						cllc ct1, mm.heap_cap
						csc ct0, 0(ct1)
						cllc csp, mm.stack_low
						cllc ct0, mm.stack_high
						csub t1, ct0, csp
						csetbounds csp, csp, t1
						cgetaddr t0, ct0
						csetaddr csp, csp, t0
						addi t0, zero, 380
						candperm csp, csp, t0
						auipcc ct0, 0
						addi t1, zero, 129
						candperm ct0, ct0, t1
						csetaddr ct0, ct0, zero
						cllc ct1, mm.cseal_seal_cap
						csc ct0, 0(ct1)
						cllc ct0, mm.alloc
						cllc ct1, mm.alloc_end
						csub t1, ct1, ct0
						csetbounds ct0, ct0, t1
						addi t1, zero, 63
						candperm ct0, ct0, t1
						csealentry ct0, ct0
						cllc ct1, mm.alloc_cap
						csc ct0, 0(ct1)
						cllc ct0, mm.cseal
						cllc ct1, mm.cseal_end
						csub t1, ct1, ct0
						csetbounds ct0, ct0, t1
						addi t1, zero, 63
						candperm ct0, ct0, t1
						csealentry ct0, ct0
						cllc ct1, mm.cseal_cap
						csc ct0, 0(ct1)
						cllc ct2, rv.main
						cllc ct0, mm.user_end
						csub t0, ct0, ct2
						csetbounds ct2, ct2, t0
						addi t0, zero, 319
						candperm ct2, ct2, t0
						.4byte 4276355291 # cclear 1, 1
						cjalr cnull, ct2
						.balign 4
		mm.alloc:		addi t2, zero, 15
						add t0, t0, t2
						xori t2, t2, -1
						and t0, t0, t2
						cllc ct2, mm.heap_cap
						clc ct2, 0(ct2)
						csetbounds ct0, ct2, t0
						cgetlen t3, ct0
						cincoffset ct2, ct2, t3
						cllc ct3, mm.heap_cap
						csc ct2, 0(ct3)
						.4byte 4276224091 # cclear 0, 128
						.4byte 4276881499 # cclear 3, 16
						cjalr cnull, ct1
						.balign 16
		mm.heap_cap:	.octa 0
		mm.alloc_end:	.balign 4
						.balign 4
		mm.cseal:		cllc ct1, mm.cseal_seal_cap
						clc ct6, 0(ct1)
						cincoffsetimm ct6, ct6, 1
						csc ct6, 0(ct1)
						csetboundsimm ct6, ct6, 1
						.4byte 4276158555 # cclear 0, 64
						cjalr cnull, ct0
						.balign 16
		mm.cseal_seal_cap:	.octa 0
		mm.cseal_end:	.balign 4
						.balign 4
		rv.main:		csc cfp, -16(csp)
						cincoffsetimm cfp, csp, -16
						cincoffsetimm csp, csp, -32
						csc cra, -16(cfp)
						cjal cra, fortytwo
		cd.ret:			mv ra, a0
						mv a0, ra
						clc cra, -16(cfp)
						cincoffsetimm csp, cfp, 16
						clc cfp, 0(cfp)
						cjalr cnull, cra
		fortytwo:		csc cfp, -16(csp)
						cincoffsetimm cfp, csp, -16
						cincoffsetimm csp, csp, -16
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
						cincoffsetimm csp, cfp, 16
						clc cfp, 0(cfp)
						cjalr cnull, cra
						.balign 16
		mm.alloc_cap:	.octa 0
		mm.cseal_cap:	.octa 0
		mm.user_end:	.balign 4
						.bss
						.balign 16
		mm.heap:		.fill 1048576, 1, 0
		mm.heap_end:	.balign 4
						.balign 16
		mm.stack_low:	.fill 1048576, 1, 0
		mm.stack_high:	.balign 4
						
						.data
						.align 6
						.global tohost
		tohost:			.dword 0
		"""
		
		XCTAssertEqual(loweredProgram.assembly, expected)
		
	}
	
}
