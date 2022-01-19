(
	evaluate(fib, constant(0) constant(1) constant(30)),
	functions:
		(fib, (prev, word) (curr, word) (iter, word),
			if(relation(named(iter), le, constant(0)),
				then:	value(named(curr)),
				else:	evaluate(fib, named(curr) binary(named(prev), add, named(curr)) binary(named(iter), sub, constant(1)))
			)
		)
)
