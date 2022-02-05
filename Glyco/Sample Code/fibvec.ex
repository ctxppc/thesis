(
	evaluate(fib, constant(30)),
	functions:
		
		(fib, (n, word),
			let(
				(lastIndex, binary(named(n), sub, constant(1))),
				in: evaluate(genFib, constant(0) named(lastIndex) vector(word, count: 30))
			)
		)
		
		(genFib, (index, word) (lastIndex, word) (nums, capability),
			if(relation(named(index), gt, named(endIndex))
				then: value(element(of: named(nums), at: named(lastIndex))),
				else: value(constant(1050))
			)
		)
		
)