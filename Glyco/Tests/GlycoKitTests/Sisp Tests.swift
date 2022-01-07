// Glyco © 2021–2022 Constantino Tsarouhas

@testable import GlycoKit
import Sisp
import XCTest

final class SispCodingTests : XCTestCase {
	
	func testEncodingEX() throws {
		
		let location = EX.Location(rawValue: "a")
		let program = EX.Program(
			.do([
				.if(
					.constant(true),
					then:	.set(location, to: .constant(1))
				),
				.return(.location(location)),
			]),
			procedures:	[]
		)
		
		let actual = try SispEncoder().encode(program).serialised()
		let expected = """
			(
				
					do(
						
							if( constant( true), then: set( a, to: constant( 1)), else: do())
							return( location( a))
					)
			)
			"""
		
		XCTAssertEqual(actual, expected)
		
	}
	
	func testDecodingEX() throws {
		
		let actual = try SispDecoder(from: """
			(
				do(
					if(
						constant(true),
						then:	set(a, to: constant(1)),
						else:	do()
					)
					return(location(a))
				),
				procedures:
			)
			""").decode(EX.Program.self)
		
		let location = EX.Location(rawValue: "a")
		let expected = EX.Program(
			.do([
				.if(
					.constant(true),
					then:	.set(location, to: .constant(1))
				),
				.return(.location(location)),
			]),
			procedures:	[]
		)
		
		XCTAssertEqual(actual, expected)
		
	}
	
}
