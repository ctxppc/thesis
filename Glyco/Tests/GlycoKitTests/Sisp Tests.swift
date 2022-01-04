// Glyco © 2021–2022 Constantino Tsarouhas

@testable import GlycoKit
import Sisp
import XCTest

final class SispCodingTests : XCTestCase {
	
	func testEncodingEX() throws {
		
		let location = EX.Location(rawValue: "a")
		let program = EX.Program(
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
			(
				
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
			(
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
		
		let location = EX.Location(rawValue: "a")
		let expected = EX.Program(
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
