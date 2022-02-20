// Sisp © 2021–2022 Constantino Tsarouhas

public final class SispEncoder : Encoder {
	
	/// Creates an encoder.
	public init() {}
	
	/// The Sisp value being encoded to.
	var sisp: Sisp = .list([])
	
	/// An index path to the Sisp value being encoded to when a container is requested from `self`.
	var indexPath: [Sisp.Index] = []
	
	// See protocol.
	public internal(set) var codingPath: [CodingKey] = []
	
	// See protocol.
	public var userInfo: [CodingUserInfoKey : Any] = [:]
	
	// See protocol.
	public func container<Key : CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
		.init(StructureEncodingContainer(
			encoder:	self,
			indexPath:	indexPath,
			codingPath:	codingPath
		))
	}
	
	// See protocol.
	public func unkeyedContainer() -> UnkeyedEncodingContainer {
		sisp[indexPath] = .list([])
		return ListEncodingContainer(encoder: self, indexPath: indexPath, codingPath: codingPath)
	}
	
	// See protocol.
	public func singleValueContainer() -> Swift.SingleValueEncodingContainer {
		SingleValueEncodingContainer(encoder: self, indexPath: indexPath, codingPath: codingPath)
	}
	
	/// Encodes `value` to a Sisp value.
	public func encode<T : Encodable>(_ value: T) throws -> Sisp {
		precondition(sisp == [], "Cannot reuse encoder")	// TODO: Make reusable by hiding actual encoder.
		try value.encode(to: self)
		return sisp
	}
	
}
