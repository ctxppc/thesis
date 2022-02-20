// Glyco © 2021–2022 Constantino Tsarouhas

@testable import GlycoKit
import XCTest

final class ProcedureTests : XCTestCase {
	
	func testSimpleInvoke() throws {
		
		let fortyTwo = EX.Label(rawValue: "fortytwo")
		let source = EX.Program(
			.evaluate(fortyTwo, []),
			functions:	[
				.init(fortyTwo, takes: [], returns: .s32, in: .value(.constant(42)))
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
						
		fortytwo:		csc cfp, -8(csp)
						cincoffsetimm cfp, csp, -8
						cincoffsetimm csp, csp, -16
						cmove cs2, cs1
						cmove cs5, cs2
						cmove cs6, cs3
						cmove cs7, cs4
						cmove cs8, cs5
						cmove cs9, cs6
						cmove cs10, cs7
						cmove cs11, cs8
						cmove ct4, cs9
						cmove cs3, cs10
						cmove cs4, cs11
						addi s1, zero, 42
						mv a0, s1
						cmove cs1, cs2
						cmove cs2, cs5
						cmove cs3, cs6
						cmove cs4, cs7
						cmove cs5, cs8
						cmove cs6, cs9
						cmove cs7, cs10
						cmove cs8, cs11
						cmove cs9, ct4
						cmove cs10, cs3
						cmove cs11, cs4
						cincoffsetimm csp, cfp, 8
						clc cfp, 0(cfp)
						cret
		rv.main:		csc cfp, -8(csp)
						cincoffsetimm cfp, csp, -8
						cincoffsetimm csp, csp, -16
						ccall fortytwo
						j cd.ret
		cd.ret:			mv s1, a0
						mv a0, s1
						cincoffsetimm csp, cfp, 8
						clc cfp, 0(cfp)
						cret
						
						.align 6
						.global tohost
		tohost:			.dword 0
		"""	// FIXME: Weird callee-saved register moves
		
		XCTAssertEqual(loweredProgram.assembly, expected)
		
	}
	
}
