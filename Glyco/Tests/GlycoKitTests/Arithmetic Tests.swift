// Glyco © 2021 Constantino Tsarouhas

import GlycoKit
import XCTest

final class ArithmeticTests : XCTestCase {
	
	func testSimpleSum() {
		
		let location = AL.Location.allocate()
		let program = AL.Program(mainEffects: [
			.assign(destination: location, source: .immediate(1)),
			.operation(destination: location, lhs: .immediate(2), operation: .add, rhs: .location(location)),
		], haltEffect: .init(result: .location(location)))
		
		let assembly = program.compiled()
		let expected = """
			addi x5, x0, 1
			sw x9, x5, 0
			addi x5, x0, 2
			lw x6, x9, 0
			add x7, x5, x6
			sw x9, x7, 0
			lw x11, x9, 0
			"""
		
		XCTAssertEqual(assembly, expected)
		
	}
	
}
