(
	evaluate(function(fib), 0 1 30),
	functions:
		(fib, takes: (prev, s32) (curr, s32) (iter, s32), returns: s32, in:
			if(relation(iter, le, 1),
				then:	value(curr),
				else:	evaluate(function(fib), curr binary(prev, add, curr) binary(iter, sub, 1))
			)
		)
)
