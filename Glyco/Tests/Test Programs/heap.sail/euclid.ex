(
	evaluate(gcd, constant(20) constant(50)),
	functions: (
		gcd,
		takes: (a, s32(), sealed: false) (b, s32(), sealed: false),
		returns: s32(),
		in: if(
			relation(named(a), eq, named(b)),
			then: value(named(a)),
			else: if(
				relation(named(a), gt, named(b)),
				then: evaluate(gcd, binary(named(a), sub, named(b)) named(b)),
				else: evaluate(gcd, named(a) binary(named(b), sub, named(a)))
			)
		)
	)
)
