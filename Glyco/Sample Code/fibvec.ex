(
	evaluate(fib, constant(30)),
	functions:
		
		(fib, takes: (n, signedWord), returns: signedWord, in:
			let(
				(lastIndex, binary(named(n), sub, constant(1))),
				in: evaluate(genFib, constant(0) named(lastIndex) vector(signedWord, count: 30))
			)
		)
		
		(genFib, takes: (index, signedWord) (lastIndex, signedWord) (nums, capability), returns: signedWord, in:
			if(relation(named(index), gt, named(endIndex))
				then: value(element(of: named(nums), at: named(lastIndex))),
				else: value(constant(1050))
			)
		)
		
)
