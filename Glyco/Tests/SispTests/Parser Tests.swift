// Glyco © 2021 Constantino Tsarouhas

import Sisp
import XCTest

final class ParserTests : XCTestCase {
	
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
	
	func testUnlabelledStructure() throws {
		
		let serialised = "person(John, age: 21, big)"
		
		let actual = try Sisp(from: serialised)
		let expected = Sisp.structure(type: "person", children: [
			.numbered(0):	"John",
			"age":			21,
			"_2":			"big",
		])
		
		XCTAssertEqual(actual, expected)
		
	}
	
}
