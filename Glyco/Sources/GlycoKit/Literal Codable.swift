// Generated using Sourcery 1.8.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


extension AL.Predicate {
	public init(boolValue: Bool) { self = .constant(boolValue) }
	public var boolValue: Bool? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

extension ALA.Source {
	public init(stringValue: String) { self = .abstract(.init(rawValue: stringValue)) }
	public var stringValue: String? {
		guard case .abstract(let value) = self else { return nil }
		return value.rawValue
	}
}

extension ALA.Source {
	public init(intValue: Int) { self = .constant(intValue) }
	public var intValue: Int? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

extension CA.Predicate {
	public init(boolValue: Bool) { self = .constant(boolValue) }
	public var boolValue: Bool? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

extension CC.Predicate {
	public init(boolValue: Bool) { self = .constant(boolValue) }
	public var boolValue: Bool? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

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

extension CD.Predicate {
	public init(boolValue: Bool) { self = .constant(boolValue) }
	public var boolValue: Bool? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

extension CE.Source {
	public init(intValue: Int) { self = .constant(intValue) }
	public var intValue: Int? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

extension CE.Target {
	public init(stringValue: String) { self = .label(.init(rawValue: stringValue)) }
	public var stringValue: String? {
		guard case .label(let value) = self else { return nil }
		return value.rawValue
	}
}

extension CL.Predicate {
	public init(boolValue: Bool) { self = .constant(boolValue) }
	public var boolValue: Bool? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

extension CL.Value {
	public init(stringValue: String) { self = .named(.init(rawValue: stringValue)) }
	public var stringValue: String? {
		guard case .named(let value) = self else { return nil }
		return value.rawValue
	}
}

extension CL.Value {
	public init(intValue: Int) { self = .constant(intValue) }
	public var intValue: Int? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

extension CL.ValueType {
	public init(stringValue: String) { self = .named(.init(rawValue: stringValue)) }
	public var stringValue: String? {
		guard case .named(let value) = self else { return nil }
		return value.rawValue
	}
}

extension CV.Predicate {
	public init(boolValue: Bool) { self = .constant(boolValue) }
	public var boolValue: Bool? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

extension DF.Predicate {
	public init(boolValue: Bool) { self = .constant(boolValue) }
	public var boolValue: Bool? {
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

extension EX.Predicate {
	public init(boolValue: Bool) { self = .constant(boolValue) }
	public var boolValue: Bool? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

extension FO.Source {
	public init(intValue: Int) { self = .constant(intValue) }
	public var intValue: Int? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

extension ID.Predicate {
	public init(boolValue: Bool) { self = .constant(boolValue) }
	public var boolValue: Bool? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

extension LS.Predicate {
	public init(boolValue: Bool) { self = .constant(boolValue) }
	public var boolValue: Bool? {
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

extension MM.Target {
	public init(stringValue: String) { self = .label(.init(rawValue: stringValue)) }
	public var stringValue: String? {
		guard case .label(let value) = self else { return nil }
		return value.rawValue
	}
}

extension MM.Source {
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

extension NT.Predicate {
	public init(boolValue: Bool) { self = .constant(boolValue) }
	public var boolValue: Bool? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

extension OB.Predicate {
	public init(boolValue: Bool) { self = .constant(boolValue) }
	public var boolValue: Bool? {
		guard case .constant(let value) = self else { return nil }
		return value
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

extension PR.Predicate {
	public init(boolValue: Bool) { self = .constant(boolValue) }
	public var boolValue: Bool? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

extension SV.Source {
	public init(stringValue: String) { self = .abstract(.init(rawValue: stringValue)) }
	public var stringValue: String? {
		guard case .abstract(let value) = self else { return nil }
		return value.rawValue
	}
}

extension SV.Source {
	public init(intValue: Int) { self = .constant(intValue) }
	public var intValue: Int? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

extension SV.Predicate {
	public init(boolValue: Bool) { self = .constant(boolValue) }
	public var boolValue: Bool? {
		guard case .constant(let value) = self else { return nil }
		return value
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

extension Λ.Predicate {
	public init(boolValue: Bool) { self = .constant(boolValue) }
	public var boolValue: Bool? {
		guard case .constant(let value) = self else { return nil }
		return value
	}
}

