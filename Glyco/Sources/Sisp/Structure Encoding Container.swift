// Glyco © 2021 Constantino Tsarouhas

struct StructureEncodingContainer<Key : CodingKey> : KeyedEncodingContainerProtocol {
	
	/// The encoder.
	let encoder: SispEncoder
	
	/// The index path to the structure being encoded.
	let indexPath: [Sisp.Index]
	
	// See protocol.
	let codingPath: [CodingKey]
	
	// See protocol.
	mutating func encodeNil(forKey key: Key) throws {
		TODO.unimplemented	// raw value encoding
	}
	
	// See protocol.
	mutating func encode(_ value: Bool, forKey key: Key) throws {
		TODO.unimplemented	// raw value encoding
	}
	
	// See protocol.
	mutating func encode(_ value: String, forKey key: Key) throws {
		TODO.unimplemented	// raw value encoding
	}
	
	// See protocol.
	mutating func encode(_ value: Double, forKey key: Key) throws {
		TODO.unimplemented	// raw value encoding
	}
	
	// See protocol.
	mutating func encode(_ value: Float, forKey key: Key) throws {
		TODO.unimplemented	// raw value encoding
	}
	
	// See protocol.
	mutating func encode(_ value: Int, forKey key: Key) throws {
		TODO.unimplemented	// raw value encoding
	}
	
	// See protocol.
	mutating func encode(_ value: Int8, forKey key: Key) throws {
		TODO.unimplemented	// raw value encoding
	}
	
	// See protocol.
	mutating func encode(_ value: Int16, forKey key: Key) throws {
		TODO.unimplemented	// raw value encoding
	}
	
	// See protocol.
	mutating func encode(_ value: Int32, forKey key: Key) throws {
		TODO.unimplemented	// raw value encoding
	}
	
	// See protocol.
	mutating func encode(_ value: Int64, forKey key: Key) throws {
		TODO.unimplemented	// raw value encoding
	}
	
	// See protocol.
	mutating func encode(_ value: UInt, forKey key: Key) throws {
		TODO.unimplemented	// raw value encoding
	}
	
	// See protocol.
	mutating func encode(_ value: UInt8, forKey key: Key) throws {
		TODO.unimplemented	// raw value encoding
	}
	
	// See protocol.
	mutating func encode(_ value: UInt16, forKey key: Key) throws {
		TODO.unimplemented	// raw value encoding
	}
	
	// See protocol.
	mutating func encode(_ value: UInt32, forKey key: Key) throws {
		TODO.unimplemented	// raw value encoding
	}
	
	// See protocol.
	mutating func encode(_ value: UInt64, forKey key: Key) throws {
		TODO.unimplemented	// raw value encoding
	}
	
	// See protocol.
	mutating func encode<T : Encodable>(_ value: T, forKey key: Key) throws {
		TODO.unimplemented	// raw value encoding
	}
	
	// See protocol.
	mutating func nestedContainer<NestedKey : CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
		let deeperIndexPath = indexPath + [.label(.init(rawValue: key.stringValue))]
		encoder.sisp[deeperIndexPath] = .structure(type: key.stringValue, children: [:])
		return .init(StructureBodyEncodingContainer(
			encoder:	encoder,
			indexPath:	deeperIndexPath,
			codingPath:	codingPath + [key]
		))
	}
	
	// See protocol.
	mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
		TODO.unimplemented	// unlabelled child list?
	}
	
	// See protocol.
	mutating func superEncoder() -> Encoder {
		TODO.unimplemented
	}
	
	// See protocol.
	mutating func superEncoder(forKey key: Key) -> Encoder {
		TODO.unimplemented
	}
	
	
}
