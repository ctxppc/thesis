(
	evaluate(function(fib), constant(0) constant(1)),
	functions:
		
		(fib,
			takes: (first, s32(), sealed: false) (second, s32(), sealed: false),
			returns: s32(),
			in: evaluate(function(recFib), constant(2) constant(29) vector(s32(), count: 30))
		)
		
		(recFib, 
			takes: (index, s32(), sealed: false) (lastIndex, s32(), sealed: false) (nums, cap(vector(of: s32(), sealed: false)), sealed: false),
			returns: s32(),
			in: if(
				relation(named(index), gt, named(lastIndex)),
				then: value(element(of: named(nums), at: named(lastIndex))),
				else: do(
					setElement(of: named(nums), at: named(index), to: binary(
						element(of: named(nums), at: binary(named(index), sub, constant(2))),
						add,
						element(of: named(nums), at: binary(named(index), sub, constant(1))),
					)),
					then: evaluate(
						function(recFib),
						binary(named(index), add, constant(1)) 
						named(lastIndex) 
						named(nums)
					)
				)
			)
		)
)
