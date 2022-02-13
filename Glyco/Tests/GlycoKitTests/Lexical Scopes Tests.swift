// Glyco © 2021–2022 Constantino Tsarouhas

import GlycoKit
import XCTest

final class LexicalScopesTests : XCTestCase {
	
	func testDefinition() throws {
		
		let program = LS.Program(
			.let([.init("answer", .source(.constant(42)))], in: .value(.source(.symbol("answer")))),
			functions: []
		)
		
		let lowered = try program.lowered(configuration: .init(target: .sail))
		
		let expected = DF.Program(
			.let([.init("answer", .source(.constant(42)))], in: .value(.source(.location("answer")))),
			functions: []
		)
		
		XCTAssertEqual(lowered, expected)
		
	}
	
}