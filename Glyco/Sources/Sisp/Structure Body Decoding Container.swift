// Glyco © 2021 Constantino Tsarouhas

import Foundation

/// A decoding container over a Sisp structure's body.
struct StructureBodyDecodingContainer<Key : CodingKey> : KeyedDecodingContainerProtocol {
	
	/// Creates a decoding container over the body of a structure with given children.
	init(children: Sisp.StructureChildren, decoder: SispDecoder) {
		self.children = children
		self.decoder = decoder
		self.allKeys = children.keys.compactMap { .init(stringValue: $0.rawValue) }
	}
	
	/// The structure's children.
	let children: Sisp.StructureChildren
	
	/// The decoder.
	let decoder: SispDecoder
	
	// See protocol.
	var codingPath: [CodingKey] { decoder.codingPath }
	
	// See protocol.
	let allKeys: [Key]
	
	// See protocol.
	func contains(_ key: Key) -> Bool {
		TODO.unimplemented
	}
	
	// See protocol.
	func decodeNil(forKey key: Key) throws -> Bool {
		try singleValueContainer(forKey: key).decodeNil()
	}
	
	// See protocol.
	func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
		try singleValueContainer(forKey: key).decode(type)
	}
	
	// See protocol.
	func decode(_ type: String.Type, forKey key: Key) throws -> String {
		try singleValueContainer(forKey: key).decode(type)
	}
	
	// See protocol.
	func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
		try singleValueContainer(forKey: key).decode(type)
	}
	
	// See protocol.
	func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
		try singleValueContainer(forKey: key).decode(type)
	}
	
	// See protocol.
	func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
		try singleValueContainer(forKey: key).decode(type)
	}
	
	// See protocol.
	func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
		try singleValueContainer(forKey: key).decode(type)
	}
	
	// See protocol.
	func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
		try singleValueContainer(forKey: key).decode(type)
	}
	
	// See protocol.
	func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
		try singleValueContainer(forKey: key).decode(type)
	}
	
	// See protocol.
	func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
		try singleValueContainer(forKey: key).decode(type)
	}
	
	// See protocol.
	func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
		try singleValueContainer(forKey: key).decode(type)
	}
	
	// See protocol.
	func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
		try singleValueContainer(forKey: key).decode(type)
	}
	
	// See protocol.
	func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
		try singleValueContainer(forKey: key).decode(type)
	}
	
	// See protocol.
	func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
		try singleValueContainer(forKey: key).decode(type)
	}
	
	// See protocol.
	func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
		try singleValueContainer(forKey: key).decode(type)
	}
	
	// See protocol.
	func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
		try singleValueContainer(forKey: key).decode(type)
	}
	
	// See protocol.
	func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
		TODO.unimplemented
	}
	
	// See protocol.
	func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
		ListDecodingContainer(decoder: .init(sisp: try child(forKey: key), userInfo: decoder.userInfo, codingPath: decoder.codingPath.appending(key)))
	}
	
	// See protocol.
	func superDecoder() throws -> Decoder {
		TODO.unimplemented
	}
	
	// See protocol.
	func superDecoder(forKey key: Key) throws -> Decoder {
		TODO.unimplemented
	}
	
	private func child(forKey key: Key) throws -> Sisp {
		guard let child = children[.init(rawValue: key.stringValue)] else {
			throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: "No child labelled “\(key.stringValue)”", underlyingError: nil))
		}
		return child
	}
	
	private func singleValueContainer(forKey key: Key) throws -> SingleValueDecodingContainer {
		.init(decoder: .init(sisp: try child(forKey: key), userInfo: decoder.userInfo, codingPath: decoder.codingPath.appending(key)))
	}
	
	private func integer<Integer : BinaryInteger>(forKey key: Key) throws -> Integer {
		let child = try child(forKey: key)
		guard case .integer(let value) = child else {
			throw DecodingError.typeMismatch(
				Integer.self,
				.init(codingPath: codingPath, debugDescription: "Cannot decode Bool; found \(child.typeDescription) instead", underlyingError: nil)
			)
		}
		guard let integer = Integer(exactly: value) else { throw Error.unrepresentableInteger(value: value, requestedType: "\(Integer.self)") }
		return integer
	}
	
	private enum Error : LocalizedError {
		
		/// An error indicating that a decoded integer cannot be represented in the requested type.
		case unrepresentableInteger(value: Int, requestedType: String)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .unrepresentableInteger(value: let value, requestedType: let requestedType):
				return "Cannot represent \(value) using \(requestedType)"
			}
		}
		
	}
	
}
