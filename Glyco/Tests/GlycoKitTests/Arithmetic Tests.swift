// Glyco © 2021 Constantino Tsarouhas

import GlycoKit
import XCTest

final class ArithmeticTests : XCTestCase {
	
	func testSimpleSum() {
		
		var context = AL.Context()
		let location = AL.Location.allocate(context: &context)
		let program = AL.Program(mainEffects: [
			.copy(destination: location, source: .immediate(1)),
			.compute(destination: location, lhs: .immediate(2), operation: .add, rhs: .location(location)),
		], haltEffect: .init(result: .location(location)))
		
		let configuration = CompilationConfiguration(target: .cheriBSD)
		let loweredProgram = program.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
			.lowered(configuration: configuration)
		let expected = """
						.text
						.attribute	4, 16
						.attribute	5, "rv64i2p0_xcheri0p0"
						.file		"<unknown>.gly"
						.globl		main
						.p2align	1
						.type		main, @function
		main:			.cfi_startproc
						addi x5, x0, 1
						sw.cap x9, 0(c5)
						addi x5, x0, 2
						lw.cap x6, 0(c9)
						add x7, x5, x6
						sw.cap x9, 0(c7)
						lw.cap x11, 0(c9)
		main.end:		.size		main, main.end-main
						.cfi_endproc
						
						.ident		"glyco version 0.1"
						.section	".note.GNU-stack","",@progbits
						.addrsig
		"""
		
		XCTAssertEqual(loweredProgram.assemblyRepresentation, expected)
		
	}
	
}
