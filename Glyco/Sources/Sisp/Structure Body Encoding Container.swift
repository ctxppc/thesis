// Sisp © 2021–2022 Constantino Tsarouhas

struct StructureBodyEncodingContainer<Key : CodingKey> : KeyedEncodingContainerProtocol {
	
	/// The encoder.
	let encoder: SispEncoder
	
	/// The index path to the structure being encoded.
	let indexPath: [Sisp.Index]
	
	// See protocol.
	let codingPath: [CodingKey]
	
	// See protocol.
	func encodeNil(forKey key: Key) throws {
		try singleValueContainer(forKey: key).encodeNil()
	}
	
	// See protocol.
	func encode(_ value: Bool, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	func encode(_ value: String, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	func encode(_ value: Double, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	func encode(_ value: Float, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	func encode(_ value: Int, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	func encode(_ value: Int8, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	func encode(_ value: Int16, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	func encode(_ value: Int32, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	func encode(_ value: Int64, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	func encode(_ value: UInt, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	func encode(_ value: UInt8, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	func encode(_ value: UInt16, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	func encode(_ value: UInt32, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	func encode(_ value: UInt64, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	func encode<T : Encodable>(_ value: T, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	func nestedContainer<NestedKey : CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
		TODO.unimplemented
	}
	
	// See protocol.
	func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
		ListEncodingContainer(
			encoder:	encoder,
			indexPath:	indexPath + [.label(.init(rawValue: key.stringValue))],
			codingPath:	codingPath + [key]
		)
	}
	
	// See protocol.
	func superEncoder() -> Encoder {
		TODO.unimplemented
	}
	
	// See protocol.
	func superEncoder(forKey key: Key) -> Encoder {
		TODO.unimplemented
	}
	
	/// Returns a single value container for encoding a value at `key`.
	private func singleValueContainer(forKey key: Key) -> SingleValueEncodingContainer {
		.init(
			encoder:	encoder,
			indexPath:	indexPath + [.label(.init(rawValue: key.stringValue))],
			codingPath:	codingPath + [key]
		)
	}
	
}
