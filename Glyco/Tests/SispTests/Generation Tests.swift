// Sisp © 2021–2022 Constantino Tsarouhas

import Sisp
import XCTest

final class GenerationTests : XCTestCase {
	
	func testSingleElementList() {
		
		let sisp = Sisp.structure(
			type: "car",
			children: [
				"size":		"large",
				"contents":	[
					.structure(type: "person", children: ["name": "John"])
				]
			]
		)
		
		let actual = sisp.serialised()
		let expected = """
			car(size: large, contents: person(name: John))
			"""
		
		XCTAssertEqual(actual, expected)
		
	}
	
	func testTopLevelList() {
		
		let sisp: Sisp = [
			.structure(type: "person", children: [
				"name":	"John",
				"kids":	["Bob", "Sarah"],
			]),
			.structure(type: "person", children: [
				"name":	"Ellis",
				"kids":	[]
			]),
		]
		
		let actual = sisp.serialised()
		let expected = """
			person(
				name: John,
				kids:
					Bob
					Sarah
			)
			person(name: Ellis, kids: )
			"""
		
		XCTAssertEqual(actual, expected)
		
	}
	
	func testMiddleList() {
		
		let sisp = Sisp.structure(type: "app", children: [
			"name":			"Glyco",
			"categories":	["Developer Tools", "Productivity"],
			"price":		99999
		])
		
		let actual = sisp.serialised()
		let expected = """
			app(
				name: Glyco,
				categories:
					"Developer Tools"
					Productivity,
				price: 99999
			)
			"""
		
		XCTAssertEqual(actual, expected)
		
	}
	
	func testMultipleLists() {
		
		let sisp = Sisp.structure(type: "topics", children: [
			"interesting":	["Compilers", "Type Theory"],
			"boring":		["Blockchain", "whatever the f Web3 is"],
		])
		
		let actual = sisp.serialised()
		let expected = """
			topics(
				interesting:
					Compilers
					"Type Theory",
				boring:
					Blockchain
					"whatever the f Web3 is"
			)
			"""
		
		XCTAssertEqual(actual, expected)
		
	}
	
	func testUnlabelledList() {
		
		let sisp = Sisp.structure(type: "fruit", children: [
			.numbered(0):	[
				"apples",
				"bananas",
				"cherries",
				.structure(type: "grapes", children: [
					"colour": "green"
				])
			],
		])
		
		let actual = sisp.serialised()
		let expected = """
			fruit(
				
					apples
					bananas
					cherries
					grapes(colour: green)
			)
			"""
		
		XCTAssertEqual(actual, expected)
		
	}
	
}
