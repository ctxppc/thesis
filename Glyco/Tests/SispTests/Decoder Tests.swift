// Sisp © 2021–2022 Constantino Tsarouhas

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
	
	func testMixedPayloads() throws {
		
		enum Value : Codable, Equatable {
			case unknown
			case string(String)
		}
		
		let actual1a = try SispDecoder(from: "unknown").decode(Value.self)
		let actual1b = try SispDecoder(from: "unknown()").decode(Value.self)
		let expected1 = Value.unknown
		XCTAssertEqual(actual1a, expected1)
		XCTAssertEqual(actual1b, expected1)
		
		let actual2 = try SispDecoder(from: "string(test)").decode(Value.self)
		let expected2 = Value.string("test")
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
	
	func testUnnamedStructure() throws {
		
		struct Toy : Codable, Equatable {
			var colour: String
			var price: Int
		}
		
		let actual = try SispDecoder(from: "(colour: black, price: 5)").decode(Toy.self)
		let expected = Toy(colour: "black", price: 5)
		XCTAssertEqual(actual, expected)
		
	}
	
	func testComplexUnnamedStructure() throws {
		
		struct Toy : Codable, Equatable {
			
			var price: Int
			
			var audience: Audience
			enum Audience : Codable, Equatable {
				case babies
				case children(maxAge: Int)
				case adults(minAge: Int)
			}
			
			var colour: Colour
			enum Colour : String, Codable, Equatable {
				case black
				case orange
			}
			
		}
		
		let actual = try SispDecoder(from: "(price: 5, audience: children(maxAge: 16), colour: black)").decode(Toy.self)
		let expected = Toy(price: 5, audience: .children(maxAge: 16), colour: .black)
		XCTAssertEqual(actual, expected)
		
	}
	
	func testUnnamedStructureInsideNamedStructure() throws {
		
		enum Toy : Codable, Equatable {
			
			case vehicle(Vehicle)
			enum Vehicle : String, Codable, Equatable {
				case car
				case truck
			}
			
			case house(House, price: Int)
			struct House : Codable, Equatable {
				
				var address: String
				
				var colour: Colour
				enum Colour : String, Codable, Equatable {
					case black
					case orange
				}
				
			}
			
		}
		
		let actual = try SispDecoder(from: #"house((address: "55, Honey Str.", colour: orange), price: 60)"#).decode(Toy.self)
		let expected = Toy.house(.init(address: "55, Honey Str.", colour: .orange), price: 60)
		XCTAssertEqual(actual, expected)
		
	}
	
	func testPartiallyStringDecodable() throws {
		
		struct Building : Decodable, Equatable {
			
			var name: Name
			enum Name : PartiallyStringDecodable, Equatable {
				init(stringValue: String) { self = .named(stringValue) }
				case unnamed
				case named(String)
			}
			
			var age: Int
			
		}
		
		let expected = Building(name: .named("White House"), age: 222)
		
		let literal = try SispDecoder(from: #"(name: "White House", age: 222)"#).decode(Building.self)
		XCTAssertEqual(literal, expected)
		
		let explicit = try SispDecoder(from: #"(name: named("White House"), age: 222)"#).decode(Building.self)
		XCTAssertEqual(explicit, expected)
		
	}
	
	func testPartiallyIntDecodable() throws {
		
		struct Building : Decodable, Equatable {
			var name: String?
			var age: Age
			enum Age : PartiallyIntDecodable, Equatable {
				init(intValue value: Int) { self = .years(value) }
				case new
				case old
				case years(Int)
			}
		}
		
		let expected = Building(name: "White House", age: .years(222))
		
		let literal = try SispDecoder(from: #"(name: "White House", age: 222)"#).decode(Building.self)
		XCTAssertEqual(literal, expected)
		
		let explicit = try SispDecoder(from: #"(name: "White House", age: years(222))"#).decode(Building.self)
		XCTAssertEqual(explicit, expected)
		
	}
	
}
