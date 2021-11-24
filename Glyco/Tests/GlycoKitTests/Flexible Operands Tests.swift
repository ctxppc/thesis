// Glyco © 2021 Constantino Tsarouhas

import GlycoKit
import XCTest

final class FlexibleOperandsTests : XCTestCase {
	
	func testPass() throws {
		
		var frame = FO.Frame()
		let a = frame.allocate(.word)
		let b = frame.allocate(.word)
		let c = frame.allocate(.word)
		
		let source = FO.Program(effects: [
			.compute(
				destination:	.frameCell(c),
				lhs:			.location(.frameCell(a)),
				operation:		.add,
				rhs:			.location(.frameCell(b))
			)
		])
		
		let expected = FL.Program(instructions: [
			.load(.word, destination: .t1, source: .location(offset: -4)),
			.load(.word, destination: .t2, source: .location(offset: -8)),
			.compute(destination: .t3, value: .registerRegister(rs1: .t1, operation: .add, rs2: .t2)),
			.store(.word, destination: .location(offset: -12), source: .t3),
		])
		
		XCTAssertEqual(try source.lowered(configuration: .init(target: .sail)), expected)
		
	}
	
}
