// Glyco © 2021–2022 Constantino Tsarouhas

@testable import GlycoKit
import Sisp
import XCTest

final class SispCodingTests : XCTestCase {
	
	func testEncodingEX() throws {
		
		let program = EX.Program(
			.if(.constant(true), then: .constant(3), else: .constant(4)),
			functions:	[]
		)
		
		let actual = try SispEncoder().encode(program).serialised()
		let expected = """
			( if( constant( true), then: constant( 3), else: constant( 4)))
			"""
		
		XCTAssertEqual(actual, expected)
		
	}
	
	func testDecodingEX() throws {
		
		let actual = try SispDecoder(from: """
			(
				if(constant(true), then: constant(3), else: constant(4)),
				functions:
			)
			""").decode(EX.Program.self)
		
		let expected = EX.Program(
			.if(.constant(true), then: .constant(3), else: .constant(4)),
			functions:	[]
		)
		
		XCTAssertEqual(actual, expected)
		
	}
	
}
