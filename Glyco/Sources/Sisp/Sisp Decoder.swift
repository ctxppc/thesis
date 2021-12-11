// Glyco © 2021 Constantino Tsarouhas

import Foundation

/// An decoder for Sisp structures.
///
/// For example, given definitions:
///
///		enum Effect : Codable {
///		    case sequence(effects: [Effect])
///		    case copy(destination: Location, source: Source)
///		}
///
///		struct Location : Codable, RawRepresentable {
///		    let rawValue: Int
///		}
///
///		enum Source : Codable {
///		    case immediate(Int)
///		    case location(Location)
///		}
///
/// the value
///
/// 	Effect.sequence(effects: [
/// 	    .copy(destination: .init(rawValue: 5), source: .immediate(10)),
/// 	    .sequence(effects: [
/// 	        .copy(destination: .init(rawValue: 15), source: .location(.init(rawValue: 20))
/// 	    ])
/// 	])
///
/// is encoded as
///
/// 	sequence(effects:
/// 	    copy(destination: 5, source: immediate(10))
/// 	    sequence(effects:
///				copy(destination: 15, source: location(20))
/// 	    )
/// 	)
public struct SispDecoder : Decoder {
	
	public init(from serialised: String) throws {
		self.init(sisp: try .init(from: serialised), userInfo: [:], codingPath: [])
	}
	
	init(sisp: Sisp, userInfo: [CodingUserInfoKey : Any], codingPath: [CodingKey]) {
		self.sisp = sisp
		self.userInfo = userInfo
		self.codingPath = codingPath
	}
	
	/// The Sisp value from which to decode.
	let sisp: Sisp
	
	// See protocol.
	public var userInfo: [CodingUserInfoKey : Any]
	
	// See protocol.
	public internal(set) var codingPath: [CodingKey]
	
	// See protocol.
	public func container<Key : CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
		.init(try SispStructureDecodingContainer(decoder: self))
	}
	
	// See protocol.
	public func unkeyedContainer() -> UnkeyedDecodingContainer {
		SispListDecodingContainer(decoder: self)
	}
	
	// See protocol.
	public func singleValueContainer() -> SingleValueDecodingContainer {
		SingleValueSispDecodingContainer(decoder: self)
	}
	
	public func decode<T : Decodable>(type: T.Type) throws -> T {
		try .init(from: self)
	}
	
}