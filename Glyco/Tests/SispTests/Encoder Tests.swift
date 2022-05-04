// Sisp © 2021–2022 Constantino Tsarouhas

import Sisp
import XCTest

final class EncoderTests : XCTestCase {
	
	func testSingleCase() throws {
		
		enum Value : String, Codable, Equatable {
			case value
		}
		
		let actual = try SispEncoder().encode(Value.value)
		let expected: Sisp = "value"
		
		XCTAssertEqual(actual, expected)
		
	}
	
	func testSingleCaseWithPayload() throws {
		
		enum Value : Codable, Equatable {
			case value(number: Int)
		}
		
		let actual = try SispEncoder().encode(Value.value(number: 5))
		let expected = Sisp.structure(type: "value", children: ["number": 5])
		
		XCTAssertEqual(actual, expected)
		
	}
	
	func testDoubleCasesWithPayload() throws {

		enum Value : Codable, Equatable {
			case number(count: Int)
			case string(text: String)
		}
		
		let actual1 = try SispEncoder().encode(Value.number(count: 5))
		let expected1 = Sisp.structure(type: "number", children: ["count": 5])
		XCTAssertEqual(actual1, expected1)
		
		let actual2 = try SispEncoder().encode(Value.string(text: "test"))
		let expected2 = Sisp.structure(type: "string", children: ["text": "test"])
		XCTAssertEqual(actual2, expected2)
		
	}

	func testNestedPayload() throws {

		enum Value : Codable, Equatable {
			case num(number: Int)
		}

		enum Thing : Codable, Equatable {
			case this(value: Value)
			case that(v: Value)
		}

		let actual = try SispEncoder().encode(Thing.this(value: .num(number: 5)))
		let expected = Sisp.structure(type: "this", children: [
			"value": .structure(type: "num", children: [
				"number": 5
			])
		])
		XCTAssertEqual(actual, expected)
		
	}
	
	func testPartiallyStringEncodable() throws {
		
		struct Building : Encodable, Equatable {
			
			var name: Name
			enum Name : PartiallyStringEncodable, Equatable {
				case unnamed
				case named(String)
				var stringValue: String? {
					guard case .named(let value) = self else { return nil }
					return value
				}
			}
			
			var age: Int
			
		}
		
		let actual = try SispEncoder().encode(Building(name: .named("White House"), age: 222))
		let expected = Sisp.structure(type: nil, children: ["name": "White House", "age": 222])
		XCTAssertEqual(actual, expected)
		
	}
	
	func testPartiallyIntEncodable() throws {
		
		struct Building : Encodable, Equatable {
			var name: String?
			var age: Age
			enum Age : PartiallyIntEncodable, Equatable {
				case new
				case old
				case years(Int)
				var intValue: Int? {
					guard case .years(let value) = self else { return nil }
					return value
				}
			}
		}
		
		let actual = try SispEncoder().encode(Building(name: "White House", age: .years(222)))
		let expected = Sisp.structure(type: nil, children: ["name": "White House", "age": 222])
		XCTAssertEqual(actual, expected)
		
	}
	
}
