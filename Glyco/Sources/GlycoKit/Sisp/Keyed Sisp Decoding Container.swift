// Glyco © 2021 Constantino Tsarouhas

import Foundation

struct KeyedSispDecodingContainer<Key : CodingKey> : KeyedDecodingContainerProtocol {
	
	init(codingPath: [CodingKey]) {
		self.codingPath = codingPath
	}
	
	// See protocol.
	let codingPath: [CodingKey]
	
	// See protocol.
	var allKeys: [Key] {
		TODO.unimplemented
	}
	
	// See protocol.
	func contains(_ key: Key) -> Bool {
		TODO.unimplemented
	}
	
	// See protocol.
	func decodeNil(forKey key: Key) throws -> Bool {
		TODO.unimplemented
	}
	
	// See protocol.
	func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
		TODO.unimplemented
	}
	
	// See protocol.
	func decode(_ type: String.Type, forKey key: Key) throws -> String {
		TODO.unimplemented
	}
	
	// See protocol.
	func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
		TODO.unimplemented
	}
	
	// See protocol.
	func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
		TODO.unimplemented
	}
	
	// See protocol.
	func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
		TODO.unimplemented
	}
	
	// See protocol.
	func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
		TODO.unimplemented
	}
	
	// See protocol.
	func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
		TODO.unimplemented
	}
	
	// See protocol.
	func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
		TODO.unimplemented
	}
	
	// See protocol.
	func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
		TODO.unimplemented
	}
	
	// See protocol.
	func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
		TODO.unimplemented
	}
	
	// See protocol.
	func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
		TODO.unimplemented
	}
	
	// See protocol.
	func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
		TODO.unimplemented
	}
	
	// See protocol.
	func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
		TODO.unimplemented
	}
	
	// See protocol.
	func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
		TODO.unimplemented
	}
	
	// See protocol.
	func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
		TODO.unimplemented
	}
	
	// See protocol.
	func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
		TODO.unimplemented
	}
	
	// See protocol.
	func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
		TODO.unimplemented
	}
	
	// See protocol.
	func superDecoder() throws -> Decoder {
		TODO.unimplemented
	}
	
	// See protocol.
	func superDecoder(forKey key: Key) throws -> Decoder {
		TODO.unimplemented
	}
	
	
}
