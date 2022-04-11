(
	evaluate(function(fib), constant(0) constant(1) constant(30)),
	functions:
		(fib, 
			takes: (prev, s32(), sealed: false) (curr, s32(), sealed: false) (iter, s32(), sealed: false), 
			returns: s32(), 
			in: if(relation(named(iter), le, constant(0)),
				then:	value(named(curr)),
				else:	evaluate(function(fib), 
					named(curr) 
					binary(named(prev), add, named(curr)) 
					binary(named(iter), sub, constant(1))
				)
			)
		)
)
