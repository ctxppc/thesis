(
	do(
		call(procedure(sum), 19 23, result: the_sum)
		return(the_sum)
	),
	procedures:
		(sum, takes: (first, s32, sealed: false) (second, s32, sealed: false), returns: s32, in:
			do(
				compute(the_result, first, add, second)
				return(the_result)
			)
		)
)