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
				.return,
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
						
		rv.runtime:		cllc ct0, mm.heap
						cllc ct1, mm.heap.end
						csub t1, ct1, ct0
						csetbounds ct0, ct0, t1
						addi t1, zero, 7
						candperm ct0, ct0, t1
						cllc ct1, mm.heap.cap
						sc.cap ct0, 0(ct1)
						auipcc ct0, 0
						csetaddr ct0, ct0, zero
						csetboundsimm ct0, ct0, 1
						addi t1, zero, 7
						candperm ct0, ct0, t1
						cllc ct1, mm.seal.cap
						sc.cap ct0, 0(ct1)
						cllc ct0, mm.alloc
						cllc ct1, mm.alloc.end
						csub t1, ct1, ct0
						csetbounds ct0, ct0, t1
						addi t1, zero, 5
						candperm ct0, ct0, t1
						csealentry ct0, ct0
						cllc ct1, mm.alloc.cap
						sc.cap ct0, 0(ct1)
						cllc ct0, mm.scall
						cllc ct1, mm.scall.end
						csub t1, ct1, ct0
						csetbounds ct0, ct0, t1
						addi t1, zero, 5
						candperm ct0, ct0, t1
						csealentry ct0, ct0
						cllc ct1, mm.scall.cap
						sc.cap ct0, 0(ct1)
						cllc ct0, rv.main
						cllc ct1, mm.user.end
						csub t1, ct1, ct0
						csetbounds ct0, ct0, t1
						addi t1, zero, 11
						candperm ct0, ct0, t1
						cmove cfp, cra
						cllc ct1, mm.scall.cap
						lc.cap ct1, 0(ct1)
						clear 0, 159
						clear 1, 254
						clear 2, 255
						clear 3, 255
						cjalr cra, ct1
						cjalr c0, ct6
		mm.alloc:		cllc ct1, mm.heap.cap
						lc.cap ct1, 0(ct1)
						csetbounds ct0, ct1, t0
						cgetlen t2, ct0
						cincoffset ct1, ct1, t2
						cllc ct2, mm.heap.cap
						sc.cap ct1, 0(ct2)
						clear 0, 192
						cjalr c0, cra
		mm.heap.cap:	.quad 0
		mm.alloc.end:	.dword 0
		mm.scall:		cllc ct1, mm.seal.cap
						lc.cap ct1, 0(ct1)
						cseal cra, cra, ct1
						cseal csp, cfp, ct1
						clear 0, 64
						clear 1, 1
						cjalr c0, ct0
		mm.seal.cap:	.quad 0
		mm.scall.end:	.dword 0
		mm.user:
		mm.alloc.cap:	.quad 0
		mm.scall.cap:	.quad 0
		rv.main:		addi s1, zero, 1
						addi t3, zero, 2
						add s1, t3, s1
						mv a0, s1
						cjalr c0, cra
		mm.user.end:	.dword 0
		mm.heap:		.fill 1048576, 1, 0
		mm.heap.end:	.dword 0
						
		rv.end:			.align 6
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
				.return,
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
						
		rv.runtime:		cllc ct0, mm.heap
						cllc ct1, mm.heap.end
						csub t1, ct1, ct0
						csetbounds ct0, ct0, t1
						addi t1, zero, 7
						candperm ct0, ct0, t1
						cllc ct1, mm.heap.cap
						sc.cap ct0, 0(ct1)
						auipcc ct0, 0
						csetaddr ct0, ct0, zero
						csetboundsimm ct0, ct0, 1
						addi t1, zero, 7
						candperm ct0, ct0, t1
						cllc ct1, mm.seal.cap
						sc.cap ct0, 0(ct1)
						cllc ct0, mm.alloc
						cllc ct1, mm.alloc.end
						csub t1, ct1, ct0
						csetbounds ct0, ct0, t1
						addi t1, zero, 5
						candperm ct0, ct0, t1
						csealentry ct0, ct0
						cllc ct1, mm.alloc.cap
						sc.cap ct0, 0(ct1)
						cllc ct0, mm.scall
						cllc ct1, mm.scall.end
						csub t1, ct1, ct0
						csetbounds ct0, ct0, t1
						addi t1, zero, 5
						candperm ct0, ct0, t1
						csealentry ct0, ct0
						cllc ct1, mm.scall.cap
						sc.cap ct0, 0(ct1)
						cllc ct0, rv.main
						cllc ct1, mm.user.end
						csub t1, ct1, ct0
						csetbounds ct0, ct0, t1
						addi t1, zero, 11
						candperm ct0, ct0, t1
						cmove cfp, cra
						cllc ct1, mm.scall.cap
						lc.cap ct1, 0(ct1)
						clear 0, 159
						clear 1, 254
						clear 2, 255
						clear 3, 255
						cjalr cra, ct1
						cjalr c0, ct6
		mm.alloc:		cllc ct1, mm.heap.cap
						lc.cap ct1, 0(ct1)
						csetbounds ct0, ct1, t0
						cgetlen t2, ct0
						cincoffset ct1, ct1, t2
						cllc ct2, mm.heap.cap
						sc.cap ct1, 0(ct2)
						clear 0, 192
						cjalr c0, cra
		mm.heap.cap:	.quad 0
		mm.alloc.end:	.dword 0
		mm.scall:		cllc ct1, mm.seal.cap
						lc.cap ct1, 0(ct1)
						cseal cra, cra, ct1
						cseal csp, cfp, ct1
						clear 0, 64
						clear 1, 1
						cjalr c0, ct0
		mm.seal.cap:	.quad 0
		mm.scall.end:	.dword 0
		mm.user:
		mm.alloc.cap:	.quad 0
		mm.scall.cap:	.quad 0
		rv.main:		addi t3, zero, 12
						addi s1, t3, -11
						addi t4, zero, 1
						beq s1, t4, cd.then
		cd.else:		addi s1, zero, 0
		cd.endif:		mv a0, s1
						cjalr c0, cra
		cd.then:		addi s1, zero, 1
						cjal c0, cd.endif
		mm.user.end:	.dword 0
		mm.heap:		.fill 1048576, 1, 0
		mm.heap.end:	.dword 0
						
		rv.end:			.align 6
						.global tohost
		tohost:			.dword 0
		"""
		
		XCTAssertEqual(actual, expected)
		
	}
	
}
