(
	locals: abstract(number, s32),
	in: do(
		pushScope
		compute(abstract(number), 1, add, 2)
		/* use number */
		popScope
		return(to: register(ra, cap))
	),
	procedures: 
)