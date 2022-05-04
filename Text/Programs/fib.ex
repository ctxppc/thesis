(
	evaluate(function(fib), 0 1 30),
	functions:
		(fib,
			takes: (prev, s32, sealed: false) (curr, s32, sealed: false) (iter, s32, sealed: false),
			returns: s32,
			in: if(relation(iter, le, 1),
				then:	value(curr),
				else:	evaluate(function(fib), curr binary(prev, add, curr) binary(iter, sub, 1))
			)
		)
)
