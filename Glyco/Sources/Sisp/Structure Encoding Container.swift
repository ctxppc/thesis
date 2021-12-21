// Glyco © 2021 Constantino Tsarouhas

struct StructureEncodingContainer<Key : CodingKey> : KeyedEncodingContainerProtocol {
	
	/// Creates a container for encoding to a structure.
	init(encoder: SispEncoder, indexPath: [Sisp.Index], codingPath: [CodingKey]) {
		self.encoder = encoder
		self.indexPath = indexPath
		self.codingPath = codingPath
	}
	
	/// The encoder.
	let encoder: SispEncoder
	
	/// The index path to the structure being encoded.
	let indexPath: [Sisp.Index]
	
	// See protocol.
	let codingPath: [CodingKey]
	
	/// A Boolean value indicating whether a structure has been encoded.
	private var encodedStructure = false
	
	// See protocol.
	mutating func encodeNil(forKey key: Key) throws {
		try singleValueContainer(forKey: key).encodeNil()
	}
	
	// See protocol.
	mutating func encode(_ value: Bool, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	mutating func encode(_ value: String, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	mutating func encode(_ value: Double, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	mutating func encode(_ value: Float, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	mutating func encode(_ value: Int, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	mutating func encode(_ value: Int8, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	mutating func encode(_ value: Int16, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	mutating func encode(_ value: Int32, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	mutating func encode(_ value: Int64, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	mutating func encode(_ value: UInt, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	mutating func encode(_ value: UInt8, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	mutating func encode(_ value: UInt16, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	mutating func encode(_ value: UInt32, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	mutating func encode(_ value: UInt64, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	mutating func encode<T : Encodable>(_ value: T, forKey key: Key) throws {
		try singleValueContainer(forKey: key).encode(value)
	}
	
	// See protocol.
	mutating func nestedContainer<NestedKey : CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
		encodeEmptyStructureIfNeeded(type: key.stringValue)
		return .init(StructureBodyEncodingContainer(
			encoder:	encoder,
			indexPath:	indexPath,
			codingPath:	codingPath + [key]
		))
	}
	
	// See protocol.
	mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
		ListEncodingContainer(
			encoder:	encoder,
			indexPath:	indexPath + [.label(.init(rawValue: key.stringValue))],
			codingPath:	codingPath + [key]
		)
	}
	
	// See protocol.
	mutating func superEncoder() -> Encoder {
		TODO.unimplemented
	}
	
	// See protocol.
	mutating func superEncoder(forKey key: Key) -> Encoder {
		TODO.unimplemented
	}
	
	/// Returns a single value container for encoding a value at `key`.
	private mutating func singleValueContainer(forKey key: Key) -> SingleValueEncodingContainer {
		encodeEmptyStructureIfNeeded(type: key.stringValue)
		return .init(
			encoder:	encoder,
			indexPath:	indexPath + [.label(.init(rawValue: key.stringValue))],
			codingPath:	codingPath + [key]
		)
	}
	
	/// Encodes an empty structure, ready to be written to.
	private mutating func encodeEmptyStructureIfNeeded(type: String?) {
		guard !encodedStructure else { return }
		encoder.sisp[indexPath] = .structure(type: type, children: [:])
		encodedStructure = true
	}
	
}
