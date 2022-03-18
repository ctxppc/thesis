// Glyco © 2021–2022 Constantino Tsarouhas

import GlycoKit
import XCTest

final class FlexibleOperandsTests : XCTestCase {
	
	func testPass() throws {
		
		var frame = FO.Frame.initial
		let a = frame.allocate(.s32)
		let b = frame.allocate(.s32)
		let c = frame.allocate(.s32)
		
		let source = FO.Program([
			.compute(.frame(c), .frame(a), .add, .frame(b))
		])
		
		let actual = try source.lowered(configuration: .init(target: .sail, callingConvention: .conventional))
		let expected = MM.Program([
			.load(.s32, into: .t4, from: .init(offset: -8)),
			.load(.s32, into: .t5, from: .init(offset: -12)),
			.compute(destination: .t4, .t4, .add, .register(.t5)),
			.store(.s32, into: .init(offset: -16), from: .t4),
		])
		
		XCTAssertEqual(actual, expected)
		
	}
	
}
