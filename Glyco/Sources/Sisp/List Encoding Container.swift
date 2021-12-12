// Glyco © 2021 Constantino Tsarouhas

struct ListEncodingContainer : UnkeyedEncodingContainer {
	
	/// The encoder.
	let encoder: SispEncoder
	
	/// The index path to the list being encoded.
	let indexPath: [Sisp.Index]
	
	// See protocol.
	let codingPath: [CodingKey]
	
	// See protocol.
	var count: Int {
		guard case .list(let elements) = sisp else { preconditionFailure("\(indexPath) contains \(sisp) and cannot be replaced by a list") }
		return elements.count
	}
	
	/// The list being encoded to.
	private var sisp: Sisp {
		get { encoder.sisp[indexPath] }
		nonmutating set { encoder.sisp[indexPath] = newValue }
		nonmutating _modify { yield &encoder.sisp[indexPath] }
	}
	
	func encodeNil() throws {
		try singleValueContainerForNextValue().encodeNil()
	}
	
	func encode(_ value: Bool) throws {
		try singleValueContainerForNextValue().encode(value)
	}
	
	// See protocol.
	func encode(_ value: String) throws {
		try singleValueContainerForNextValue().encode(value)
	}
	
	// See protocol.
	func encode(_ value: Double) throws {
		try singleValueContainerForNextValue().encode(value)
	}
	
	// See protocol.
	func encode(_ value: Float) throws {
		try singleValueContainerForNextValue().encode(value)
	}
	
	// See protocol.
	func encode(_ value: Int) throws {
		try singleValueContainerForNextValue().encode(value)
	}
	
	// See protocol.
	func encode(_ value: Int8) throws {
		try singleValueContainerForNextValue().encode(value)
	}
	
	// See protocol.
	func encode(_ value: Int16) throws {
		try singleValueContainerForNextValue().encode(value)
	}
	
	// See protocol.
	func encode(_ value: Int32) throws {
		try singleValueContainerForNextValue().encode(value)
	}
	
	// See protocol.
	func encode(_ value: Int64) throws {
		try singleValueContainerForNextValue().encode(value)
	}
	
	// See protocol.
	func encode(_ value: UInt) throws {
		try singleValueContainerForNextValue().encode(value)
	}
	
	// See protocol.
	func encode(_ value: UInt8) throws {
		try singleValueContainerForNextValue().encode(value)
	}
	
	// See protocol.
	func encode(_ value: UInt16) throws {
		try singleValueContainerForNextValue().encode(value)
	}
	
	// See protocol.
	func encode(_ value: UInt32) throws {
		try singleValueContainerForNextValue().encode(value)
	}
	
	// See protocol.
	func encode(_ value: UInt64) throws {
		try singleValueContainerForNextValue().encode(value)
	}
	
	// See protocol.
	func encode<T : Encodable>(_ value: T) throws {
		try singleValueContainerForNextValue().encode(value)
	}
	
	// See protocol.
	func nestedContainer<NestedKey : CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
		let endIndex = count
		return .init(StructureEncodingContainer(
			encoder:	encoder,
			indexPath:	indexPath + [.position(endIndex)],
			codingPath:	codingPath + [IndexCodingKey(intValue: endIndex)]
		))
	}
	
	// See protocol.
	func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
		TODO.unimplemented
	}
	
	// See protocol.
	func superEncoder() -> Encoder {
		TODO.unimplemented
	}
	
	/// Returns a single value container for encoding the next value in the container.
	private func singleValueContainerForNextValue() -> SingleValueEncodingContainer {
		let endIndex = count
		return .init(
			encoder:	encoder,
			indexPath:	indexPath + [.position(endIndex)],
			codingPath:	codingPath + [IndexCodingKey(intValue: endIndex)]
		)
	}
	
}
