// Glyco © 2021 Constantino Tsarouhas

import Foundation

/// A decoding container over a Sisp structure.
struct SispStructureDecodingContainer<Key : CodingKey> : KeyedDecodingContainerProtocol {
	
	/// Creates a decoding container over a structure with given name and children.
	init(structureType: String, childrenByLabel: [String : Sisp], decoder: SispDecoder) {
		self.structureType = structureType
		self.childrenByLabel = childrenByLabel
		self.decoder = decoder
	}
	
	/// The structure's type.
	private let structureType: String
	
	/// The structure's children, keyed by label.
	private let childrenByLabel: [String : Sisp]
	
	/// The decoder.
	let decoder: SispDecoder
	
	// See protocol.
	var codingPath: [CodingKey] { decoder.codingPath }
	
	// See protocol.
	var allKeys: [Key] {
		guard let key = Key(stringValue: structureType) else { return [] }
		return [key]
	}
	
	// See protocol.
	func contains(_ key: Key) -> Bool {
		key.stringValue == structureType
	}
	
	// See protocol.
	func decodeNil(forKey key: Key) throws -> Bool {
		try check(key)
		TODO.unimplemented
	}
	
	// See protocol.
	func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
		TODO.unimplemented	// raw value decoding
	}
	
	// See protocol.
	func decode(_ type: String.Type, forKey key: Key) throws -> String {
		TODO.unimplemented	// raw value decoding
	}
	
	// See protocol.
	func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
		TODO.unimplemented	// raw value decoding
	}
	
	// See protocol.
	func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
		TODO.unimplemented	// raw value decoding
	}
	
	// See protocol.
	func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
		TODO.unimplemented	// raw value decoding
	}
	
	// See protocol.
	func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
		TODO.unimplemented	// raw value decoding
	}
	
	// See protocol.
	func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
		TODO.unimplemented	// raw value decoding
	}
	
	// See protocol.
	func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
		TODO.unimplemented	// raw value decoding
	}
	
	// See protocol.
	func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
		TODO.unimplemented	// raw value decoding
	}
	
	// See protocol.
	func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
		TODO.unimplemented	// raw value decoding
	}
	
	// See protocol.
	func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
		TODO.unimplemented	// raw value decoding
	}
	
	// See protocol.
	func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
		TODO.unimplemented	// raw value decoding
	}
	
	// See protocol.
	func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
		TODO.unimplemented	// raw value decoding
	}
	
	// See protocol.
	func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
		TODO.unimplemented	// raw value decoding
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
	
	private func check(_ key: Key) throws {
		guard contains(key) else { throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: "Can only decode structure of type “\(structureType)”, not “\(key.stringValue)”", underlyingError: nil)) }
	}
	
}
