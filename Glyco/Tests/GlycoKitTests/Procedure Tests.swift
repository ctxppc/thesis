// Glyco © 2021–2022 Constantino Tsarouhas

@testable import GlycoKit
import XCTest

final class ProcedureTests : XCTestCase {
	
	func testSimpleInvoke() throws {
		
		let fortyTwo = EX.Label(rawValue: "fortytwo")
		let source = EX.Program(
			.evaluate(fortyTwo, []),
			functions:	[
				.init(fortyTwo, [], .constant(42))
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
						
		fortytwo:		addi a0, zero, 42
						ret
		main:			j fortytwo
						
						.align 6
						.global tohost
		tohost:			.dword 0
		"""
		
		XCTAssertEqual(loweredProgram.assembly, expected)
		
	}
	
}
