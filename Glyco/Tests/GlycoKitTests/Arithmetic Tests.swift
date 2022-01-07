// Glyco © 2021–2022 Constantino Tsarouhas

@testable import GlycoKit
import XCTest

final class ArithmeticTests : XCTestCase {
	
	func testSimpleSum() throws {
		
		let location = AL.AbstractLocation(rawValue: "a")
		
		let program = AL.Program(
			.do([
				location <- .immediate(1),
				.compute(.immediate(2), .add, .location(.abstract(location)), to: .abstract(location)),
				.return(.location(.abstract(location)))
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
		let expected = """
						.text
						
						.globl _start
		_start:			la t0, _trap_vector
						csrw mtvec, t0
						la t0, _main
						csrw mepc, t0
						mret
						
						.align 4
		_trap_vector:	li gp, 3
						j _exit
						
		_exit:			auipc t5, 0x1
						sw gp, tohost, t5
						j _exit
						
		_main:			la ra, main
						jalr ra, ra
						li gp, 1
						j _exit
						
		main:			addi s1, zero, 1
						addi t1, zero, 2
						add s1, t1, s1
						mv a0, s1
						ret
						
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
			.do([
				.compute(.immediate(12), .subtract, .immediate(11), to: .abstract(testedNumber)),
				.if(
					.relation(.location(.abstract(testedNumber)), .equal, .immediate(1)),
					then:	isEven <- .immediate(1),
					else:	isEven <- .immediate(0)
				),
				.return(.location(.abstract(isEven)))
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
		
		let actual = loweredProgram.assembly
		let expected = """
						.text
						
						.globl _start
		_start:			la t0, _trap_vector
						csrw mtvec, t0
						la t0, _main
						csrw mepc, t0
						mret
						
						.align 4
		_trap_vector:	li gp, 3
						j _exit
						
		_exit:			auipc t5, 0x1
						sw gp, tohost, t5
						j _exit
						
		_main:			la ra, main
						jalr ra, ra
						li gp, 1
						j _exit
						
		main:			addi t1, zero, 12
						addi s1, t1, -11
						addi t2, zero, 1
						beq s1, t2, BB0
						j BB1
		BB0:			addi s2, zero, 1
						j BB2
		BB1:			addi s2, zero, 0
						j BB2
		BB2:			mv a0, s2
						ret
						
						.align 6
						.global tohost
		tohost:			.dword 0
		"""
		
		XCTAssertEqual(actual, expected)
		
	}
	
}
