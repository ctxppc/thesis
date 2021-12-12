// Glyco © 2021 Constantino Tsarouhas

import GlycoKit
import Sisp
import XCTest

final class SispCodingTests : XCTestCase {
	
	func testEncodingEX() throws {
		
		let location = EX.Location.location(id: 1)
		let program = EX.Program.program(
			body: .sequence([
				.if(
					.constant(value: true),
					then:	.assign(location, to: .constant(value: 1))
				),
				.return(.location(location: location)),
			]),
			procedures:	[]
		)
		
		let actual = try SispEncoder().encode(program).serialised()
		let expected = """
			program(
				body:
					sequence(
						
							if( constant(value: true), then: assign( location(id: 1), to: constant(value: 1)), else: sequence())
							return( location(location: location(id: 1)))
					)
			)
			"""
		
		XCTAssertEqual(actual, expected)
		
	}
	
	func testDecodingEX() throws {
		
		let actual = try SispDecoder(from: """
			program(
				body: sequence(
					if(
						constant(value: true),
						then:	assign(location(id: 1), to: constant(value: 1)),
						else:	sequence()
					)
					return(location(location: location(id: 1)))
				),
				procedures:
			)
			""").decode(type: EX.Program.self)
		
		let location = EX.Location.location(id: 1)
		let expected = EX.Program.program(
			body: .sequence([
				.if(
					.constant(value: true),
					then:	.assign(location, to: .constant(value: 1))
				),
				.return(.location(location: location)),
			]),
			procedures:	[]
		)
		
		XCTAssertEqual(actual, expected)
		
	}
	
}
