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
						
		rv.main:		cincoffsetimm ct0, csp, -8
						sc.cap cfp, 0(ct0)
						cmove cfp, ct0
						cincoffsetimm csp, csp, -8
						call fortytwo
		cd.ret:			mv s1, a0
						mv a0, s1
						cincoffsetimm csp, cfp, 8
						lc.cap cfp, 0(cfp)
						ret.cap
		fortytwo:		cincoffsetimm ct0, csp, -8
						sc.cap cfp, 0(ct0)
						cmove cfp, ct0
						cincoffsetimm csp, csp, -8
						addi s1, zero, 42
						mv a0, s1
						cincoffsetimm csp, cfp, 8
						lc.cap cfp, 0(cfp)
						ret.cap
						
						.align 6
						.global tohost
		tohost:			.dword 0
		"""
		
		XCTAssertEqual(loweredProgram.assembly, expected)
		
	}
	
}
