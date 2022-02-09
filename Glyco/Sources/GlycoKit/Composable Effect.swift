// Glyco © 2021–2022 Constantino Tsarouhas

/// An effect that can be composed out of effects.
protocol ComposableEffect {
	
	/// Creates an effect that sequentially executes `effects`.
	static func `do`(_ effects: [Self]) -> Self
	
	/// The subeffects of the `do` effect, or `nil` if `self` is not a `do` effect.
	///
	/// - Invariant: For any array of effects `effects`, `Self.do(effects).subeffects` is equal to `effects`.
	var subeffects: [Self]? { get }
	
}

@resultBuilder
enum EffectBuilder<Effect : ComposableEffect> {
	
	static func buildBlock(_ effects: Effect...) -> Effect {
		buildArray(effects)
	}
	
	static func buildArray(_ effects: [Effect]) -> Effect {
		.do(effects).flattened2()
	}
	
	static func buildOptional(_ effect: Effect?) -> Effect {
		effect ?? .do([])
	}
	
	static func buildEither(first effect: Effect) -> Effect {
		effect
	}
	
	static func buildEither(second effect: Effect) -> Effect {
		effect
	}
	
}

extension ComposableEffect {
	
	/// Creates an effect using `builder`.
	static func `do`(@EffectBuilder<Self> _ builder: () throws -> Self) rethrows -> Self {
		try builder()
	}
	
	/// Returns a copy of `self` where no `do` effect is directly nested in another `do` effect.
	fileprivate func flattened2() -> Self {
		guard let subeffects = subeffects else { return self }
		let flattenedSubeffects = subeffects.map { $0.flattened2() }
		if let (subeffect, tail) = flattenedSubeffects.splittingFirst(), tail.isEmpty {
			return subeffect
		} else {
			return .do(subeffects)
		}
	}
	
}
