(let(
	(even, λ(takes: (n, s32, sealed: false), returns: s32, in:
		if(
			relation(n, le, 0), 
			then: value(1),
			else: evaluate(odd, binary(n, sub, 1))
		)
	))
	(odd, λ(takes: (n, s32, sealed: false), returns: s32, in:
		if(
			relation(n, le, 0), 
			then: value(0),
			else: evaluate(even, binary(n, sub, 1))
		)
	)), in:
	evaluate(even, 420)
))