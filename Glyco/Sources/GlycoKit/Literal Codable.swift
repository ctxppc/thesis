// Generated using Sourcery 1.7.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


extension CC.Source {
	public init(stringValue: String) { self = .location(.init(rawValue: stringValue)) }
	public var stringValue: String? {
		guard case .location(let value) = self else { return nil }
		return value.rawValue
	}
}

extension CC.Source {
	public init(intValue: Int) { self = .constant(intValue) }
	public var intValue: Int? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

extension EX.Value {
	public init(stringValue: String) { self = .named(.init(rawValue: stringValue)) }
	public var stringValue: String? {
		guard case .named(let value) = self else { return nil }
		return value.rawValue
	}
}

extension EX.Value {
	public init(intValue: Int) { self = .constant(intValue) }
	public var intValue: Int? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

extension LS.Source {
	public init(stringValue: String) { self = .named(.init(rawValue: stringValue)) }
	public var stringValue: String? {
		guard case .named(let value) = self else { return nil }
		return value.rawValue
	}
}

extension LS.Source {
	public init(intValue: Int) { self = .constant(intValue) }
	public var intValue: Int? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

extension NT.Value {
	public init(stringValue: String) { self = .named(.init(rawValue: stringValue)) }
	public var stringValue: String? {
		guard case .named(let value) = self else { return nil }
		return value.rawValue
	}
}

extension NT.Value {
	public init(intValue: Int) { self = .constant(intValue) }
	public var intValue: Int? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

extension NT.ValueType {
	public init(stringValue: String) { self = .named(.init(rawValue: stringValue)) }
	public var stringValue: String? {
		guard case .named(let value) = self else { return nil }
		return value.rawValue
	}
}

extension OB.Value {
	public init(stringValue: String) { self = .named(.init(rawValue: stringValue)) }
	public var stringValue: String? {
		guard case .named(let value) = self else { return nil }
		return value.rawValue
	}
}

extension OB.Value {
	public init(intValue: Int) { self = .constant(intValue) }
	public var intValue: Int? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

extension OB.ValueType {
	public init(stringValue: String) { self = .named(.init(rawValue: stringValue)) }
	public var stringValue: String? {
		guard case .named(let value) = self else { return nil }
		return value.rawValue
	}
}

extension Λ.Value {
	public init(stringValue: String) { self = .named(.init(rawValue: stringValue)) }
	public var stringValue: String? {
		guard case .named(let value) = self else { return nil }
		return value.rawValue
	}
}

extension Λ.Value {
	public init(intValue: Int) { self = .constant(intValue) }
	public var intValue: Int? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

