// Glyco © 2021–2022 Constantino Tsarouhas

protocol Name : RawCodable, Hashable, ExpressibleByStringLiteral where RawValue == String {
	init(rawValue: RawValue)
}

protocol Named {
	
	/// The value's name.
	var name: Name { get }
	associatedtype Name : GlycoKit.Name
	
}

struct Bag<NameType : Name> {
	
	mutating func uniqueName(from prefix: String) -> NameType {
		
		let prefix = prefix
			.split(separator: "$", maxSplits: 1, omittingEmptySubsequences: true)
			.first
			.map(String.init) ?? prefix
		
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

extension Name {
	public init(stringLiteral: String) {
		self.init(rawValue: stringLiteral)
	}
}

extension Sequence where Element : Named {
	
	/// Accesses the first element named `name`.
	subscript (name: Element.Name) -> Element? {
		first(where: { $0.name == name })
	}
	
}
