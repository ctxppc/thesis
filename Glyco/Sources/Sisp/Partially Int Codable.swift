// Sisp © 2021–2022 Constantino Tsarouhas

/// A value that may be encoded as an integer.
///
/// Encoders supporting this protocol check conformance to this protocol and attempt to encode values using the integer value instead of using `encode(to:)`.
public protocol PartiallyIntEncodable : Encodable {
	
	/// The integer value of `self`, or `nil` if `self` cannot be represented as an integer.
	var intValue: Int? { get }
	
}

/// A value that may be decoded as an integer.
///
/// Decoders supporting this protocol check conformance to this protocol and decode values using the integer value when available.
public protocol PartiallyIntDecodable : Decodable {
	
	/// Creates an instance of `Self` using given integer value.
	init(intValue: Int)
	
}

/// A value that can be encoded and decoded as an integer.
public typealias PartiallyIntCodable = PartiallyIntEncodable & PartiallyIntDecodable
