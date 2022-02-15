(
	evaluate(fib, constant(0) constant(1) constant(30)),
	functions:
		(fib, takes: (prev, signedWord()) (curr, signedWord()) (iter, signedWord()), returns: signedWord(), in:
			if(relation(named(iter), le, constant(0)),
				then:	value(named(curr)),
				else:	evaluate(fib, named(curr) binary(named(prev), add, named(curr)) binary(named(iter), sub, constant(1)))
			)
		)
)
