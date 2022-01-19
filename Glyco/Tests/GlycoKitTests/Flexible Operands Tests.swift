// Glyco © 2021–2022 Constantino Tsarouhas

import GlycoKit
import XCTest

final class FlexibleOperandsTests : XCTestCase {
	
	func testPass() throws {
		
		var frame = FO.Frame()
		let a = frame.allocate(.word)
		let b = frame.allocate(.word)
		let c = frame.allocate(.word)
		
		let source = FO.Program([
			.compute(.location(.frameCell(a)), .add, .location(.frameCell(b)), to: .frameCell(c))
		])
		
		let actual = try source.lowered(configuration: .init(target: .sail))
		let expected = FL.Program([
			.load(.word, into: .t1, from: .init(offset: -4)),
			.load(.word, into: .t2, from: .init(offset: -8)),
			.compute(into: .t3, value: .registerRegister(.t1, .add, .t2)),
			.store(.word, into: .init(offset: -12), from: .t3),
		])
		
		XCTAssertEqual(actual, expected)
		
	}
	
}
