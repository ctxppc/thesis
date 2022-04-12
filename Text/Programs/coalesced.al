(
	locals: abstract(number, s32),
	in: do(
		pushScope()
		compute(abstract(number), constant(1), add, constant(2))
		/* use number */
		popScope()
		return(to: register(ra, cap))
	),
	procedures: 
)