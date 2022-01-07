(
	call(fib, constant(0) constant(1) constant(30)),
	procedures: 
		(fib, (prev, word) (curr, word) (iter, word),
			if(relation(location(iter), le, constant(0)),
				then:	return(location(curr)),
				else:	call(fib, location(curr) binary(location(prev), add, location(curr)) binary(location(iter), sub, constant(1)))
			)
		)
)
