// Sisp © 2021–2022 Constantino Tsarouhas

/// A value that can be omitted in an encoded representation when it has a default value.
@propertyWrapper
public struct Defaulted<ValueProvider : DefaultValueProvider> : Codable, Equatable where ValueProvider.Value : Codable & Equatable {
	
	public typealias Value = ValueProvider.Value
	
	/// Creates a defaulted value with given initial value.
	public init(wrappedValue: Value) {
		self.wrappedValue = wrappedValue
	}
	
	/// Creates a defaulted value using the default value.
	public init() {
		self.init(wrappedValue: ValueProvider.defaultValue)
	}
	
	// See protocol.
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if container.decodeNil() {
			self.init()
		} else {
			self.init(wrappedValue: try container.decode(Value.self))
		}
	}
	
	/// The wrapped value.
	public var wrappedValue: Value
	
	// See protocol.
	public func encode(to encoder: Encoder) throws {
		guard wrappedValue != ValueProvider.defaultValue else { return }
		var container = encoder.singleValueContainer()
		try container.encode(wrappedValue)
	}
	
}

public protocol DefaultValueProvider {
	associatedtype Value
	static var defaultValue: Value { get }
}

extension KeyedEncodingContainerProtocol {
	
	/// Encodes `value` for `key` if `value` isn't a default value.
	public mutating func encode<P>(_ value: Defaulted<P>, forKey key: Key) throws {
		guard value.wrappedValue != P.defaultValue else { return }
		try encode(value.wrappedValue, forKey: key)
	}
	
}

extension KeyedDecodingContainerProtocol {
	
	/// Decodes `value` for `key` if present, or returns a default value otherwise.
	public func decode<P>(_ type: Defaulted<P>.Type, forKey key: Key) throws -> Defaulted<P> {
		try decodeIfPresent(P.Value.self, forKey: key).map(Defaulted.init(wrappedValue:)) ?? .init()
	}
	
}

public enum False : DefaultValueProvider {
	public static let defaultValue = false
}

public enum Empty<C : ExpressibleByArrayLiteral> : DefaultValueProvider {
	public static var defaultValue: C { [] }
}
