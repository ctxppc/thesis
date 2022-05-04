// Sisp © 2021–2022 Constantino Tsarouhas

/// A value that may be encoded as a Boolean value.
///
/// Encoders supporting this protocol check conformance to this protocol and attempt to encode values using the Boolean value instead of using `encode(to:)`.
public protocol PartiallyBoolEncodable : Encodable {
	
	/// The Boolean value of `self`, or `nil` if `self` cannot be represented as a Boolean value.
	var boolValue: Bool? { get }
	
}

/// A value that may be decoded as a Boolean value.
///
/// Decoders supporting this protocol check conformance to this protocol and decode values using the Boolean value when available.
public protocol PartiallyBoolDecodable : Decodable {
	
	/// Creates an instance of `Self` using given Boolean value.
	init(boolValue: Bool)
	
}

/// A value that can be encoded and decoded as a Boolean value.
public typealias PartiallyBoolCodable = PartiallyBoolEncodable & PartiallyBoolDecodable
