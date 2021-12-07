// Glyco © 2021 Constantino Tsarouhas

import Sisp
import XCTest

final class GenerationTests : XCTestCase {
	
	func testCar() {
		
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
		let expected = "car ( size: large , contents: person ( name: John , ) , )"
		
		XCTAssertEqual(actual, expected)
		
	}
	
}
