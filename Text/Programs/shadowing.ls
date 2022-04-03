(
	value(
		let((answer, source(constant(42))), in:
			do(
				let((answer, source(constant(28))), in: do()),
				then: source(named(answer))
			)
		)
	),
	functions:
)