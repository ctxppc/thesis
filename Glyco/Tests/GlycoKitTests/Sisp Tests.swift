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
			.label("attr"),
			.integer(1234),
			.word("type"),
			.label("attr"),
		]
		
		XCTAssertEqual(actual, expected)
		
	}
	
	func testEmptyLabelMislexing() {
		XCTAssertThrowsError(try SispLexeme.lexemes(from: "(attr1::)"))
	}
	
	func testQuotedLexing() throws {
		
		let input = #"value(attr1: "test text", attr2: "more text")"#
		
		let actual = try SispLexeme.lexemes(from: input)
		let expected: [SispLexeme] = [
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
	
	func testHTMLSisp() throws {
		
		let serialised = """
		dtd(type: html)
		html(
			head:	title(text: "Welcome to my website!")
					script(href: "google.com/spy.js", type: "text/javascript"),
					
			body:	p(text: "Please feel yourselves at home!")
		)
		"""
		
		let actual = try Sisp(from: serialised)
		let expected = Sisp.list([
			.structure(type: "dtd", children: ["type": .string("html")]),
			.structure(type: "html", children: [
				"head": .list([
					.structure(type: "title", children: ["text": .string("Welcome to my website!")]),
					.structure(type: "script", children: ["href": .string("google.com/spy.js"), "type": .string("text/javascript")]),
				]),
				"body": .structure(type: "p", children: ["text": .string("Please feel yourselves at home!")]),
			])
		])
		
		XCTAssertEqual(actual, expected)
		
	}
	
}
