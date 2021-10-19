// Glyco © 2021 Constantino Tsarouhas

import GlycoKit
import XCTest

final class ArithmeticTests : XCTestCase {
	
	func testSimpleSum() {
		
		var context = AL.Context()
		let location = AL.Location.allocate(context: &context)
		let program = AL.Program(mainEffects: [
			.assign(destination: location, source: .immediate(1)),
			.operation(destination: location, lhs: .immediate(2), operation: .add, rhs: .location(location)),
		], haltEffect: .init(result: .location(location)))
		
		let assembly = program.compiled()
		let expected = """
						.text
						.attribute	4, 16
						.attribute	5, "rv64i2p0_xcheri0p0"
						.file		"<unknown>.gly"
						
						# -- Begin function _start
						.globl		_start
						.p2align	2
						.type		_start, @function
		_start:			addi x5, x0, 1
						sw x9, x5, 0
						addi x5, x0, 2
						lw x6, x9, 0
						add x7, x5, x6
						sw x9, x7, 0
						lw x11, x9, 0
		.Lfunc_end0:	.size		_start, .Lfunc_end0-_start
						# -- End function _start
						
						.ident		"glyco version 0.1"
						.section	".note.GNU-stack","",@progbits
						.addrsig
		"""
		
		XCTAssertEqual(assembly, expected)
		
	}
	
}
