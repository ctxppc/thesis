// Glyco © 2021 Constantino Tsarouhas

@testable import Sisp
import XCTest

final class LexerTests : XCTestCase {
	
	func testValid() throws {
		
		let input = " )( ())( attr:1234 type\n\nattr: "
		
		let actual = try Lexeme.lexemes(from: input)
		let expected: [Lexeme] = [
			.trailingParenthesis,
			.leadingParenthesis,
			.leadingParenthesis,
			.trailingParenthesis,
			.trailingParenthesis,
			.leadingParenthesis,
			.label("attr"),
			.integer(1234),
			.word("type"),
			.label("attr"),
		]
		
		XCTAssertEqual(actual, expected)
		
	}
	
	func testEmptyLabel() {
		XCTAssertThrowsError(try Lexeme.lexemes(from: "(attr1::)"))
	}
	
	func testQuoted() throws {
		
		let input = #"value(attr1: "test text", attr2: "more text")"#
		
		let actual = try Lexeme.lexemes(from: input)
		let expected: [Lexeme] = [
			.word("value"),
			.leadingParenthesis,
			.label("attr1"),
			.quotedString("test text"),
			.separator,
			.label("attr2"),
			.quotedString("more text"),
			.trailingParenthesis,
		]
		
		XCTAssertEqual(actual, expected)
		
	}
	
	func testEscaped() throws {
		
		let input = #"value(attr1: "test text", "at tr2": "more""text")"#
		
		let actual = try Lexeme.lexemes(from: input)
		let expected: [Lexeme] = [
			.word("value"),
			.leadingParenthesis,
			.label("attr1"),
			.quotedString("test text"),
			.separator,
			.quotedLabel("at tr2"),
			.quotedString(#"more"text"#),
			.trailingParenthesis,
		]
		
		XCTAssertEqual(actual, expected)
		
	}
	
}
