// Sisp © 2021–2022 Constantino Tsarouhas

struct SingleValueEncodingContainer : Swift.SingleValueEncodingContainer {
	
	/// The encoder.
	let encoder: SispEncoder
	
	/// The index path to the value being encoded.
	let indexPath: [Sisp.Index]
	
	// See protocol.
	let codingPath: [CodingKey]
	
	/// The value being encoded to.
	private var sisp: Sisp {
		get { encoder.sisp[indexPath] }
		nonmutating set { encoder.sisp[indexPath] = newValue }
		nonmutating _modify { yield &encoder.sisp[indexPath] }
	}
	
	// See protocol.
	func encodeNil() throws {
		ensureSingleValue(newValue: Any?.none)
		sisp = []
	}
	
	// See protocol.
	func encode(_ value: Bool) throws {
		ensureSingleValue(newValue: value)
		sisp = .string(value.description)
	}
	
	// See protocol.
	func encode(_ value: String) throws {
		ensureSingleValue(newValue: value)
		sisp = .string(value)
	}
	
	// See protocol.
	func encode(_ value: Double) throws {
		try encode(exactly: value)
	}
	
	// See protocol.
	func encode(_ value: Float) throws {
		try encode(exactly: value)
	}
	
	// See protocol.
	func encode(_ value: Int) throws {
		try encode(exactly: value)
	}
	
	// See protocol.
	func encode(_ value: Int8) throws {
		try encode(exactly: value)
	}
	
	// See protocol.
	func encode(_ value: Int16) throws {
		try encode(exactly: value)
	}
	
	// See protocol.
	func encode(_ value: Int32) throws {
		try encode(exactly: value)
	}
	
	// See protocol.
	func encode(_ value: Int64) throws {
		try encode(exactly: value)
	}
	
	// See protocol.
	func encode(_ value: UInt) throws {
		try encode(exactly: value)
	}
	
	// See protocol.
	func encode(_ value: UInt8) throws {
		try encode(exactly: value)
	}
	
	// See protocol.
	func encode(_ value: UInt16) throws {
		try encode(exactly: value)
	}
	
	// See protocol.
	func encode(_ value: UInt32) throws {
		try encode(exactly: value)
	}
	
	// See protocol.
	func encode(_ value: UInt64) throws {
		try encode(exactly: value)
	}
	
	// See protocol.
	func encode<T : Encodable>(_ value: T) throws {
		
		ensureSingleValue(newValue: value)
		
		let previousIndexPath = encoder.indexPath
		encoder.indexPath = indexPath
		defer { encoder.indexPath = previousIndexPath }
		
		let previousCodingPath = encoder.codingPath
		encoder.codingPath = codingPath
		defer { encoder.codingPath = previousCodingPath }
		
		try value.encode(to: encoder)
		
	}
	
	private func encode<Integer : BinaryInteger>(exactly value: Integer) throws {
		ensureSingleValue(newValue: value)
		guard let encoded = Int(exactly: value) else {
			throw EncodingError.invalidValue(value, .init(codingPath: codingPath, debugDescription: "\(value) is not representable as an Int", underlyingError: nil))
		}
		sisp = .integer(encoded)
	}
	
	private func encode<Number : BinaryFloatingPoint>(exactly value: Number) throws {
		ensureSingleValue(newValue: value)
		guard let encoded = Int(exactly: value) else {
			throw EncodingError.invalidValue(value, .init(codingPath: codingPath, debugDescription: "\(value) is not representable as an Int", underlyingError: nil))
		}
		sisp = .integer(encoded)
	}
	
	private func ensureSingleValue<T>(newValue: T) {
		precondition(sisp == [], "Cannot replace \(sisp) by \(newValue) at \(indexPath)")
	}
	
}
