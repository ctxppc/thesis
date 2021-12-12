// Glyco © 2021 Constantino Tsarouhas

import Sisp
import XCTest

final class DecoderTests : XCTestCase {
	
	func testSingleSimpleCase() throws {
		
		enum Value : String, Codable, Equatable {
			case value
		}
		
		let actual = try SispDecoder(from: "value").decode(Value.self)
		let expected = Value.value
		
		XCTAssertEqual(actual, expected)
		
	}
	
	func testSingleCaseSinglePayload() throws {
		
		enum Value : Codable, Equatable {
			case value(number: Int)
		}
		
		let actual = try SispDecoder(from: "value(number: 5)").decode(Value.self)
		let expected = Value.value(number: 5)
		
		XCTAssertEqual(actual, expected)
		
	}
	
	func testDoubleCaseSinglePayload() throws {
		
		enum Value : Codable, Equatable {
			case number(number: Int)
			case string(string: String)
		}
		
		let actual1 = try SispDecoder(from: "number(number: 5)").decode(Value.self)
		let expected1 = Value.number(number: 5)
		XCTAssertEqual(actual1, expected1)
		
		let actual2 = try SispDecoder(from: "string(string: test)").decode(Value.self)
		let expected2 = Value.string(string: "test")
		XCTAssertEqual(actual2, expected2)
		
	}
	
	func testNestedPayload() throws {
		
		enum Value : Codable, Equatable {
			case value(number: Int)
		}
		
		enum Thing : Codable, Equatable {
			case this(value: Value)
			case that(v: Value)
		}
		
		let actual = try SispDecoder(from: "this(value: value(number: 5))").decode(Thing.self)
		let expected = Thing.this(value: .value(number: 5))
		XCTAssertEqual(actual, expected)
		
		let wrongLabel = try SispDecoder(from: "that(value: value(number: 5))")
		XCTAssertThrowsError(try wrongLabel.decode(Thing.self))
		
	}
	
}
