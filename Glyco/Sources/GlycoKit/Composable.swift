// Glyco © 2021–2022 Constantino Tsarouhas

protocol Composable {
	
	/// Builds a value of type `Self` consisting of `elements`.
	static func `do`(_ elements: [Self]) -> Self
	
}

@resultBuilder
enum EffectBuilder<Effect : Composable> {
	
	static func buildBlock(_ effects: Effect...) -> Effect {
		.do(effects)
	}
	
	static func buildArray(_ effects: [Effect]) -> Effect {
		.do(effects)
	}
	
	static func buildOptional(_ effect: Effect?) -> Effect {
		effect.map { .do([$0]) } ?? .do([])
	}
	
	static func buildEither(first effect: Effect) -> Effect {
		effect
	}
	
	static func buildEither(second effect: Effect) -> Effect {
		effect
	}
	
}

extension Composable {
	
	/// Creates a value of type `Self` using `builder`.
	static func from(@EffectBuilder<Self> _ builder: () throws -> Self) rethrows -> Self {
		try builder()
	}
	
}
