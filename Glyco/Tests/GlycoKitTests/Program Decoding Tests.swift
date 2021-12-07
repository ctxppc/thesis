// Glyco © 2021 Constantino Tsarouhas

import GlycoKit
import Sisp
import XCTest

final class DecodingTests : XCTestCase {
	
	func testEX() throws {
		
		let actual = try SispDecoder(from: """
			program(
				body: compound(statements:
					conditional(
						predicate:		constant(value: true),
						affirmative:	assign(destination: location(id: 1), value: constant(value: 1)),
						negative:		compound(statements:)
					)
					return(result: location(location: location(id: 1)))
				),
				procedures:
			)
			""").decode(type: EX.Program.self)
		
		let location = EX.Location.location(id: 1)
		let expected = EX.Program.program(
			body: .compound(statements: [
				.conditional(
					predicate:		.constant(value: true),
					affirmative:	.assign(destination: location, value: .constant(value: 1)),
					negative:		.compound(statements: [])
				),
				.return(result: .location(location: location)),
			]),
			procedures:	[]
		)
		
		XCTAssertEqual(actual, expected)
		
	}
	
}
