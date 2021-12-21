program(
	invoke(fib, constant(0) constant(1) constant(30)),
	procedures: 
		procedure(fib, parameters: parameter(prev, type: word) parameter(curr, type: word) parameter(iterations, type: word),
		if(relation(location(iterations), le, immediate(0)),
			then:	return(location(curr)),
			else:	sequence(
				assign(next, to: binary(location(prev), add, location(curr)))
				assign(limit, to: binary(location(iterations), sub, constant(1)))
				invoke(fib, location(curr) location(next) location(limit))
			)
		)
	)
)
