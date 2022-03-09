// Glyco © 2021–2022 Constantino Tsarouhas

@resultBuilder
enum ArrayBuilder<Element> {
	
	static func buildBlock(_ statements: [Element]...) -> [Element] {
		statements.flatMap { $0 }
	}
	
	static func buildArray(_ statements: [Element]) -> [Element] {
		statements
	}
	
	static func buildArray(_ statements: [[Element]]) -> [Element] {
		statements.flatMap { $0 }
	}
	
	static func buildOptional(_ statements: [Element]?) -> [Element] {
		statements ?? []
	}
	
	static func buildEither(first statements: [Element]) -> [Element] {
		statements
	}
	
	static func buildEither(second statements: [Element]) -> [Element] {
		statements
	}
	
	static func buildExpression(_ statement: Element) -> [Element] {
		[statement]
	}
	
	static func buildExpression(_ statements: [Element]) -> [Element] {
		statements
	}
	
	static func buildExpression<S : Sequence>(_ statements: S) -> [Element] where S.Element == Element {
		.init(statements)
	}
	
	static func buildExpression(_: ()) -> [Element] {
		[]
	}
	
}
