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
/// 	    copy(destination: 5, source: immediate(10)),
/// 	    sequence(effects:
///				copy(destination: 15, source: location(20))
/// 	    )
/// 	)
public struct SispDecoder : Decoder {
	
	// See protocol.
	public var userInfo: [CodingUserInfoKey : Any]
	
	// See protocol.
	public private(set) var codingPath: [CodingKey]
	
	// See protocol.
	public func container<Key : CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
		TODO.unimplemented
	}
	
	// See protocol.
	public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
		TODO.unimplemented
	}
	
	// See protocol.
	public func singleValueContainer() throws -> SingleValueDecodingContainer {
		TODO.unimplemented
	}
	
}
