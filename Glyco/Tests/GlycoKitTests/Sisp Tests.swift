// Glyco © 2021 Constantino Tsarouhas

@testable import GlycoKit
import XCTest

final class SispTests : XCTestCase {
	
	func testValidLexing() throws {
		
		let input = " )( ())( attr:1234 type\n\nattr: "
		
		let actual = try SispLexeme.lexemes(from: input)
		let expected: [SispLexeme] = [
			.trailingParenthesis,
			.leadingParenthesis,
			.leadingParenthesis,
			.trailingParenthesis,
			.trailingParenthesis,
			.leadingParenthesis,
			.attributeLabel("attr"),
			.integer(1234),
			.typeName("type"),
			.attributeLabel("attr"),
		]
		
		XCTAssertEqual(actual, expected)
		
	}
	
	func testEmptyAttributes() throws {
		XCTAssertThrowsError(try SispLexeme.lexemes(from: "(attr1::)"))
	}
	
}
