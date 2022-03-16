// Glyco © 2021–2022 Constantino Tsarouhas

@testable import GlycoKit
import XCTest

final class ArithmeticTests : XCTestCase {
	
	func testSimpleSum() throws {
		
		let location: AL.AbstractLocation = "a"
		
		let program = AL.Program(
			locals: try .init([.abstract(location) ~ .s32]),
			in: .do([
				.set(.abstract(location), to: .constant(1)),
				.compute(.abstract(location), .constant(2), .add, .abstract(location)),
				.set(.register(.a0), to: .abstract(location)),
				.return(to: .register(.ra, .cap)),
			]),
			procedures: []
		)
		
		let configuration = CompilationConfiguration(target: .sail)
		let loweredProgram = try program.lowered(configuration: configuration)
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
		mm.alloc:		cllc ct1, mm.heap.cap
						clc ct1, 0(ct1)
						csetbounds ct0, ct1, t0
						cgetlen t2, ct0
						cincoffset ct1, ct1, t2
						cllc ct2, mm.heap.cap
						csc ct1, 0(ct2)
						clear 0, 192
						cjalr cnull, cra
		mm.heap.cap:	.octa 0
		mm.alloc.end:	.align 4
		mm.user:
		mm.alloc.cap:	.octa 0
		mm.scall.cap:	.octa 0
						.align 4
		rv.main:		addi s1, zero, 1
						addi s1, s1, 2
						mv a0, s1
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
	
	func testEqualsOne() throws {
		
		let testedNumber: AL.AbstractLocation = "a"
		let isEven: AL.AbstractLocation = "b"
		
		let program = AL.Program(
			locals: try .init([.abstract(testedNumber) ~ .s32, .abstract(isEven) ~ .s32]),
			in: .do([
				.compute(.abstract(testedNumber), .constant(12), .sub, .constant(11)),
				.if(
					.relation(.abstract(testedNumber), .eq, .constant(1)),
					then:	.set(.abstract(isEven), to: .constant(1)),
					else:	.set(.abstract(isEven), to: .constant(0))
				),
				.set(.register(.a0), to: .abstract(isEven)),
				.return(to: .register(.ra, .cap)),
			]),
			procedures:	[]
		)
		
		let configuration = CompilationConfiguration(target: .sail)
		let loweredProgram = try program.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
		
		let actual = loweredProgram.assembly
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
		mm.alloc:		cllc ct1, mm.heap.cap
						clc ct1, 0(ct1)
						csetbounds ct0, ct1, t0
						cgetlen t2, ct0
						cincoffset ct1, ct1, t2
						cllc ct2, mm.heap.cap
						csc ct1, 0(ct2)
						clear 0, 192
						cjalr cnull, cra
		mm.heap.cap:	.octa 0
		mm.alloc.end:	.align 4
		mm.user:
		mm.alloc.cap:	.octa 0
		mm.scall.cap:	.octa 0
						.align 4
		rv.main:		addi t3, zero, 12
						addi s1, t3, -11
						addi t4, zero, 1
						beq s1, t4, cd.then
		cd.else:		addi s1, zero, 0
		cd.endif:		mv a0, s1
						cjalr cnull, cra
		cd.then:		addi s1, zero, 1
						cjal cnull, cd.endif
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
		
		XCTAssertEqual(actual, expected)
		
	}
	
}
