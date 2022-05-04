// Sisp © 2021–2022 Constantino Tsarouhas

/// A value that may be encoded as a string.
///
/// Encoders supporting this protocol check conformance to this protocol and attempt to encode values using the string value instead of using `encode(to:)`.
public protocol PartiallyStringEncodable : Encodable {
	
	/// The string value of `self`, or `nil` if `self` cannot be represented as a string.
	var stringValue: String? { get }
	
}

/// A value that may be decoded as a string.
///
/// Decoders supporting this protocol check conformance to this protocol and decode values using the string value when available.
public protocol PartiallyStringDecodable : Decodable {
	
	/// Creates an instance of `Self` using given string value.
	init(stringValue: String)
	
}

/// A value that can be encoded and decoded as a string.
public typealias PartiallyStringCodable = PartiallyStringEncodable & PartiallyStringDecodable
