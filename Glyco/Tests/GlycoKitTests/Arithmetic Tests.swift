// Glyco © 2021 Constantino Tsarouhas

import GlycoKit
import XCTest

final class ArithmeticTests : XCTestCase {
	
	func testSimpleSum() throws {
		
		let location = AL.Location(rawValue: 0)
		
		let program = AL.Program(
			effect:	.copy(
				destination: location,
				source: .immediate(1),
				successor: .compute(
					destination: location,
					lhs: .immediate(2),
					operation: .add,
					rhs: .location(location),
					successor: .return(result: .location(location))
				)
			)
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
						la t0, main
						csrw mepc, t0
						mret
						
						.align 4
		_trap_vector:	li gp, 3
						j _exit
						
		_exit:			auipc t5, 0x1
						sw gp, tohost, t5
						j _exit
						
		main:					addi s1, zero, 1
						addi t1, zero, 2
						add s1, t1, s1
						mv a0, s1
						cret
						
						.align 6
						.global tohost
		tohost:			.dword 0
		"""
		
		XCTAssertEqual(loweredProgram.body, expected)
		
	}
	
}
