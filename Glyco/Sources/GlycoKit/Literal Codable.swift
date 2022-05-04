// Generated using Sourcery 1.7.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Sisp

extension OB.Value : PartiallyStringCodable {
	public init(stringValue: String) { self = .named(.init(rawValue: stringValue)) }
	public var stringValue: String? {
		guard case .named(let value) = self else { return nil }
		return value.rawValue
	}
}
extension OB.Value : PartiallyIntCodable {
	public init(intValue: Int) { self = .constant(intValue) }
	public var intValue: Int? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}
