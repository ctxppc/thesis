// Glyco © 2021–2022 Constantino Tsarouhas

import GlycoKit
import XCTest

final class LexicalScopesTests : XCTestCase {
	
	func testDefinition() throws {
		
		let program = LS.Program(
			.let([.init("answer", .source(.constant(42)))], in: .value(.source(.named("answer")))),
			functions: []
		)
		
		let lowered = try program.lowered(configuration: .init(target: .sail, callingConvention: .conventional))
		
		let expected = DF.Program(
			.let([.init("ls.answer", .source(.constant(42)))], in: .value(.source(.location("ls.answer")))),
			functions: []
		)
		
		XCTAssertEqual(lowered, expected)
		
	}
	
}
