(
	evaluate(fib, constant(0) constant(1) constant(30)),
	functions:
		(fib, (prev, word) (curr, word) (iter, word),
			if(relation(symbol(iter), le, constant(0)),
				then:	value(symbol(curr)),
				else:	evaluate(fib, symbol(curr) binary(symbol(prev), add, symbol(curr)) binary(symbol(iter), sub, constant(1)))
			)
		)
)
