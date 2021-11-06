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
					
					.align		4
					.globl		main
					.type		main, @function
		main:		ccall		body
					ecall
		main.end:	.size		main, main.end-main
					
					.align		4
					.globl		body
					.type		body, @function
		body:		entry: addi t1, zero, 1
					cincoffsetimm ct0, cfp, -4
					sw.cap t1, 0(ct0)
					addi t1, zero, 2
					cincoffsetimm ct0, cfp, -12
					lw.cap t2, 0(ct0)
					add t3, t1, t2
					cincoffsetimm ct0, cfp, -8
					sw.cap t3, 0(ct0)
					cincoffsetimm ct0, cfp, -16
					lw.cap a0, 0(ct0)
					cret
		body.end:	.size		body, body.end-body
					
					.section	.tohost, "aw", @progbits
					
					.align		6
					.global		tohost
		tohost:		.dword		0
					
					.align		6
					.global		fromhost
		fromhost:	.dword		0
		"""
		
		XCTAssertEqual(loweredProgram.body, expected)
		
	}
	
}
