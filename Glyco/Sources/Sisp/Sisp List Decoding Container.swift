// Glyco © 2021 Constantino Tsarouhas

struct SispListDecodingContainer : UnkeyedDecodingContainer {
	
	/// Creates a decoding container.
	init(decoder: SispDecoder) {
		switch decoder.sisp {
			case .list(let children):	self.children = children[...]
			case let value:				self.children = [value]
		}
		self.decoder = decoder
	}
	
	/// The list's remaining children.
	private var children: ArraySlice<Sisp>
	
	/// The decoder.
	let decoder: SispDecoder
	
	// See protocol.
	var codingPath: [CodingKey] { decoder.codingPath }
	
	// See protocol.
	var count: Int? { children.count }
	
	// See protocol.
	var isAtEnd: Bool { children.isEmpty }
	
	// See protocol.
	var currentIndex: Int { children.startIndex }
	
	// See protocol.
	mutating func decodeNil() -> Bool {
		singleValueContainerForNextValue().decodeNil()
	}
	
	// See protocol.
	mutating func decode(_ type: Bool.Type) throws -> Bool {
		try singleValueContainerForNextValue().decode(type)
	}
	
	// See protocol.
	mutating func decode(_ type: String.Type) throws -> String {
		try singleValueContainerForNextValue().decode(type)
	}
	
	// See protocol.
	mutating func decode(_ type: Double.Type) throws -> Double {
		try singleValueContainerForNextValue().decode(type)
	}
	
	// See protocol.
	mutating func decode(_ type: Float.Type) throws -> Float {
		try singleValueContainerForNextValue().decode(type)
	}
	
	// See protocol.
	mutating func decode(_ type: Int.Type) throws -> Int {
		try singleValueContainerForNextValue().decode(type)
	}
	
	// See protocol.
	mutating func decode(_ type: Int8.Type) throws -> Int8 {
		try singleValueContainerForNextValue().decode(type)
	}
	
	// See protocol.
	mutating func decode(_ type: Int16.Type) throws -> Int16 {
		try singleValueContainerForNextValue().decode(type)
	}
	
	// See protocol.
	mutating func decode(_ type: Int32.Type) throws -> Int32 {
		try singleValueContainerForNextValue().decode(type)
	}
	
	// See protocol.
	mutating func decode(_ type: Int64.Type) throws -> Int64 {
		try singleValueContainerForNextValue().decode(type)
	}
	
	// See protocol.
	mutating func decode(_ type: UInt.Type) throws -> UInt {
		try singleValueContainerForNextValue().decode(type)
	}
	
	// See protocol.
	mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
		try singleValueContainerForNextValue().decode(type)
	}
	
	// See protocol.
	mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
		try singleValueContainerForNextValue().decode(type)
	}
	
	// See protocol.
	mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
		try singleValueContainerForNextValue().decode(type)
	}
	
	// See protocol.
	mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
		try singleValueContainerForNextValue().decode(type)
	}
	
	// See protocol.
	mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
		try singleValueContainerForNextValue().decode(type)
	}
	
	// See protocol.
	mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
		.init(try SispStructureDecodingContainer(decoder: decoderForNextValue()))
	}
	
	// See protocol.
	mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
		Self(decoder: decoderForNextValue())
	}
	
	// See protocol.
	mutating func superDecoder() throws -> Decoder {
		TODO.unimplemented
	}
	
	private mutating func singleValueContainerForNextValue() -> SingleValueSispDecodingContainer {
		.init(decoder: decoderForNextValue())
	}
	
	private mutating func decoderForNextValue() -> SispDecoder {
		.init(
			sisp:		children.removeFirst(),
			userInfo:	decoder.userInfo,
			codingPath:	decoder.codingPath.appending(IndexCodingKey(intValue: currentIndex))
		)
	}
	
	private struct IndexCodingKey : CodingKey {
		
		init?(stringValue: String) {
			guard let intValue = Int(stringValue) else { return nil }
			self.intValue = intValue
			self.stringValue = stringValue
		}
		
		init(intValue: Int) {
			self.intValue = intValue
			self.stringValue = "\(intValue)"
		}
		
		var intValue: Int?
		var stringValue: String
		
	}
	
}
