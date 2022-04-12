(
	locals: abstract(number, s32) abstract(three, s32),
	in: do(
		pushScope()
		compute(abstract(three), constant(1), add, constant(2))
		set(abstract(number), to: abstract(three))
		/* use number */
		popScope()
		return(to: register(ra, cap))
	),
	procedures: 
)