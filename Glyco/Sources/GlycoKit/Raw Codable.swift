// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

public protocol RawEncodable : Encodable, RawRepresentable where RawValue : Encodable {}
public protocol RawDecodable : Decodable, RawRepresentable where RawValue : Decodable {}
public typealias RawCodable = RawEncodable & RawDecodable

extension RawEncodable {
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(rawValue)
	}
}

extension RawDecodable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let rawValue = try container.decode(RawValue.self)
		guard let decoded = Self(rawValue: rawValue) else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "No value of type \(Self.self) corresponds with decoded raw value \(rawValue)")
		}
		self = decoded
	}
}
