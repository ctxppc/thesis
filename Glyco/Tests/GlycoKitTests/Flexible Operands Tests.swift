// Glyco © 2021–2022 Constantino Tsarouhas

import GlycoKit
import XCTest

final class FlexibleOperandsTests : XCTestCase {
	
	func testPass() throws {
		
		let configuration = CompilationConfiguration(target: .sail, callingConvention: .conventional)
		
		var frame = FO.Frame.initial(configuration: configuration)
		let a = frame.allocate(.s32, configuration: configuration)
		let b = frame.allocate(.s32, configuration: configuration)
		let c = frame.allocate(.s32, configuration: configuration)
		
		let source = FO.Program([
			.compute(.frame(c), .frame(a), .add, .frame(b))
		])
		
		let actual = try source.lowered(configuration: configuration)
		let expected = MM.Program([
			.load(.s32, into: .t4, from: .init(offset: -16)),
			.load(.s32, into: .t5, from: .init(offset: -20)),
			.compute(destination: .t4, .t4, .add, .register(.t5)),
			.store(.s32, into: .init(offset: -24), from: .t4),
		])
		
		XCTAssertEqual(actual, expected)
		
	}
	
}
