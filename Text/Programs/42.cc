(
	do(
		call(procedure(sum), 19 23, result: the_sum)
		return(the_sum)
	),
	procedures:
		(sum, takes: (first, s32) (second, s32), returns: s32, in:
			do(
				compute(the_result, first, add, second)
				return(the_result)
			)
		)
)