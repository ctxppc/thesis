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
						
		rv.main:		addi s1, zero, 1
						addi t1, zero, 2
						add s1, t1, s1
						mv a0, s1
						cret
						
						.align 6
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
						
		rv.main:		addi t1, zero, 12
						addi s1, t1, -11
						addi t2, zero, 1
						beq s1, t2, cd.then
						j cd.else
		cd.then:		addi s1, zero, 1
						j cd.endif
		cd.else:		addi s1, zero, 0
						j cd.endif
		cd.endif:		mv a0, s1
						cret
						
						.align 6
						.global tohost
		tohost:			.dword 0
		"""
		
		XCTAssertEqual(actual, expected)
		
	}
	
}
