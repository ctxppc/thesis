// Glyco © 2021–2022 Constantino Tsarouhas

/// An effect that can be composed out of effects.
protocol ComposableEffect {
	
	/// Builds a value of type `Self` consisting of `elements`.
	static func `do`(_ elements: [Self]) -> Self
	
}

@resultBuilder
enum EffectBuilder<Effect : ComposableEffect> {
	
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
