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
						
		main:			addi s1, zero, 1
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
	
	func testEqualsOne() throws {
		
		let testedNumber = AL.Location(rawValue: 0)
		let isEven = AL.Location(rawValue: 0)
		
		let program = AL.Program(
			effect:	.compute(
				destination:	testedNumber,
				lhs:			.immediate(12),
				operation:		.subtract,
				rhs:			.immediate(11),
				successor: .conditional(
					predicate:		.relation(lhs: .location(testedNumber), relation: .equal, rhs: .immediate(1)),
					affirmative:	.copy(destination: isEven, source: .immediate(1), successor: .none),
					negative:		.copy(destination: isEven, source: .immediate(0), successor: .none),
					successor:		.return(result: .location(isEven))
				)
			)
		)
		
		try program.write(to: .init(fileURLWithPath: "EqualsOne.al"))
		
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
						
		main:			addi t1, zero, 12
						subtracti s1, t1, 11
						addi t2, zero, 1
						beq s1, t2, BB0
						j BB1
		BB0:				addi s1, zero, 1
						j BB2
		BB1:				addi s1, zero, 0
						j BB2
		BB2:				mv a0, s1
						cret
						
						.align 6
						.global tohost
		tohost:			.dword 0
		"""
		
		XCTAssertEqual(loweredProgram.body, expected)
		
	}
	
}
