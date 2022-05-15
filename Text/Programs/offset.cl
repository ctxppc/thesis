(
	let(
		(offset, 5)
		(closure, λ(takes: (n, s32), returns: s32, in:
			value(binary(n, add, offset))
		)),
		in: evaluate(closure, 600)
	)
)