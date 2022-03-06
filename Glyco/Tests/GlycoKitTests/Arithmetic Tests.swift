// Glyco © 2021–2022 Constantino Tsarouhas

@testable import GlycoKit
import XCTest

final class ArithmeticTests : XCTestCase {
	
	func testSimpleSum() throws {
		
		let location = AL.AbstractLocation(rawValue: "a")
		
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
		rv.main:		addi s1, zero, 1
						addi t1, zero, 2
						add s1, t1, s1
						mv a0, s1
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
	
	func testEqualsOne() throws {
		
		let testedNumber = AL.AbstractLocation(rawValue: "a")
		let isEven = AL.AbstractLocation(rawValue: "b")
		
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
		
		let actual = loweredProgram.assembly
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
		rv.main:		addi t1, zero, 12
						addi s1, t1, -11
						addi t2, zero, 1
						beq s1, t2, cd.then
		cd.else:		addi s1, zero, 0
		cd.endif:		mv a0, s1
						ret.cap
		cd.then:		addi s1, zero, 1
						j cd.endif
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
