(
	let(
		(one, 1)
		(plusOne, λ(takes: (term, s32), returns: s32, in:
			value(binary(one, add, term))
		)),
		in: evaluate(plusOne, 2)
	)
)