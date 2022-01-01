// Sisp © 2021–2022 Constantino Tsarouhas

import Foundation

/// A decoding container over a Sisp structure.
struct StructureDecodingContainer<Key : CodingKey> : KeyedDecodingContainerProtocol {
	
	/// Creates a decoding container.
	init(structureType: String, structureChildren: Sisp.StructureChildren, decoder: SispDecoder) {
		self.structureType = structureType
		self.structureChildren = structureChildren
		self.decoder = decoder
	}
	
	/// The structure.
	var sisp: Sisp { decoder.sisp }
	
	/// The structure's type.
	private let structureType: String
	
	/// The structure's children.
	private let structureChildren: Sisp.StructureChildren
	
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
		return false	// nil cannot be represented (yet)
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
	func decode<T : Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
		TODO.unimplemented
	}
	
	// See protocol.
	func nestedContainer<NestedKey : CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
		try check(key)
		var deeperDecoder = decoder
		deeperDecoder.codingPath.append(key)
		return .init(StructureBodyDecodingContainer(children: structureChildren, decoder: deeperDecoder))
	}
	
	// See protocol.
	func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
		TODO.unimplemented	// unlabelled child list?
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
		guard contains(key) else {
			throw DecodingError.keyNotFound(
				key,
				.init(
					codingPath: codingPath,
					debugDescription: "Can only decode structure of type “\(structureType)”, not “\(key.stringValue)”",
					underlyingError: nil
				)
			)
		}
	}
	
}
