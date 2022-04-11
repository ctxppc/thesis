(
	do(
		call(procedure(sum), constant(19) constant(23), result: the_sum)
		return(location(the_sum))
	),
	procedures:
		(sum, takes: (first, s32(), sealed: false) (second, s32(), sealed: false), returns: s32(), in:
			do(
				compute(the_result, location(first), add, location(second))
				return(location(the_result))
			)
		)
)