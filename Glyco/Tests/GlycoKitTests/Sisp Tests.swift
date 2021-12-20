// Glyco © 2021 Constantino Tsarouhas

import GlycoKit
import Sisp
import XCTest

final class SispCodingTests : XCTestCase {
	
	func testEncodingEX() throws {
		
		let location = EX.Location.local("a")
		let program = EX.Program.program(
			.sequence([
				.if(
					.constant(true),
					then:	.assign(location, to: .constant(1))
				),
				.return(.location(location)),
			]),
			procedures:	[]
		)
		
		let actual = try SispEncoder().encode(program).serialised()
		let expected = """
			program(
				
					sequence(
						
							if( constant( true), then: assign( a, to: constant( 1)), else: sequence())
							return( location( a))
					)
			)
			"""
		
		XCTAssertEqual(actual, expected)
		
	}
	
	func testDecodingEX() throws {
		
		let actual = try SispDecoder(from: """
			program(
				sequence(
					if(
						constant(true),
						then:	assign( a, to: constant(1)),
						else:	sequence()
					)
					return(location( a))
				),
				procedures:
			)
			""").decode(EX.Program.self)
		
		let location = EX.Location.local("a")
		let expected = EX.Program.program(
			.sequence([
				.if(
					.constant(true),
					then:	.assign(location, to: .constant(1))
				),
				.return(.location(location)),
			]),
			procedures:	[]
		)
		
		XCTAssertEqual(actual, expected)
		
	}
	
}
