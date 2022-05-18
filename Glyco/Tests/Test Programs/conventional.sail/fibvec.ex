(
	evaluate(function(fib), 0 1),
	functions:
		(fib, takes: (first, s32) (second, s32), returns: s32,
			in: evaluate(function(recFib), 2 29 vector(0, count: 30))
		)
		
		(recFib, 
			takes: (index, s32) (lastIndex, s32) (nums, cap(vector(of: s32, sealed: false))),
			returns: s32,
			in: if(
				relation(index, gt, lastIndex),
				then: value(element(of: nums, at: lastIndex)),
				else: do(
					setElement(of: nums, at: index, to: binary(
						element(of: nums, at: binary(index, sub, 2)),
						add,
						element(of: nums, at: binary(index, sub, 1)),
					)),
					then: evaluate(function(recFib), binary(index, add, 1) named(lastIndex) named(nums))
				)
			)
		)
)
