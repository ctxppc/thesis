// Glyco © 2021–2022 Constantino Tsarouhas

import Sisp

public protocol Name : RawCodable, Hashable, ExpressibleByStringInterpolation, CustomStringConvertible where RawValue == String {
	init(rawValue: RawValue)
}

extension Name {
	
	public init(stringLiteral: String) {
		self.init(rawValue: stringLiteral)
	}
	
	public var description: String {
		rawValue
	}
	
}

public protocol Named {
	
	/// The value's name.
	var name: Name { get }
	associatedtype Name : GlycoKit.Name
	
}

struct Bag<NameType : Name, Language : GlycoKit.Language> {
	
	mutating func uniqueName(from prefix: String) -> NameType {
		
		let suffixlessPrefix = prefix
			.split(separator: "$", maxSplits: 1, omittingEmptySubsequences: true)
			.first
			.map(String.init) ?? prefix
		
		let langlessPrefix = suffixlessPrefix
			.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: true)
			.splittingLast()
			.map { String($0.tail) } ?? suffixlessPrefix
		
		let prefix = "\(Language.name.lowercased().applyingTransform(.toLatin, reverse: false) ?? "").\(langlessPrefix)"
		
		if let uses = usesByPrefix[prefix] {
			defer { usesByPrefix[prefix] = uses + 1 }
			return .init(rawValue: "\(prefix)$\(uses)")
		} else {
			usesByPrefix[prefix] = 1
			return .init(rawValue: prefix)
		}
		
	}
	
	private var usesByPrefix: [String : Int] = [:]
	
}

extension Sequence where Element : Named {
	
	/// Accesses the first element named `name`.
	subscript (name: Element.Name) -> Element? {
		first(where: { $0.name == name })
	}
	
}
