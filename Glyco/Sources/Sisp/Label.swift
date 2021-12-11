// Glyco © 2021 Constantino Tsarouhas

public enum Label : Hashable {
	
	case named(String)
	case numbered(Int)
	
	public init<S : StringProtocol>(rawValue: S) {
		if case ("_", let tail)? = rawValue.splittingFirst(), let n = Int(tail) {
			self = .numbered(n)
		} else {
			self = .named(.init(rawValue))
		}
	}
	
}

extension Label : RawRepresentable {
	
	public init(rawValue: String) {
		if case ("_", let tail)? = rawValue.splittingFirst(), let n = Int(tail) {
			self = .numbered(n)
		} else {
			self = .named(rawValue)
		}
	}
	
	public var rawValue: String {
		switch self {
			case .named(let name):	return name
			case .numbered(let n):	return "_\(n)"
		}
	}
	
}

extension Label : CustomStringConvertible {
	public var description: String { rawValue }
}

extension Label : ExpressibleByStringLiteral {
	public init(stringLiteral value: String) {
		self.init(rawValue: value)
	}
}
