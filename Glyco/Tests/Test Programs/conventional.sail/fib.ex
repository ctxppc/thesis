(
	evaluate(fib, constant(0) constant(1) constant(30)),
	functions:
		(fib, takes: (prev, s32()) (curr, s32()) (iter, s32()), returns: s32(), in:
			if(relation(named(iter), le, constant(1)),
				then:	value(named(curr)),
				else:	evaluate(fib, named(curr) binary(named(prev), add, named(curr)) binary(named(iter), sub, constant(1)))
			)
		)
)
