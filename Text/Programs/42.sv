(
	do(
		pushScope
		set(abstract(cc.retcap), to: register(ra, cap(code)))
		set(register(a0), to: 19)
		set(register(a1), to: 23)
		call(capability(to: sum), parameters: a0 a1)
		set(abstract(the_sum), to: register(a0, s32))
		set(register(a0), to: the_sum)
		set(register(ra), to: cc.retcap)
		popScope
		return(to: register(ra, cap(code)))
	),
	procedures: (
		sum,
		in: do(
			pushScope
			set(abstract(cc.savedS1), to: register(s1, registerDatum))
			/* same for s2 through s10 */
			set(abstract(cc.savedS11), to: register(s11, registerDatum))
			set(abstract(cc.retcap), to: register(ra, cap(code)))
			set(abstract(first), to: register(a0, s32))
			set(abstract(second), to: register(a1, s32))
			compute(abstract(the_result), first, add, second)
			set(register(a0), to: the_result)
			set(register(s1), to: cc.savedS1)
			/* same for s2 through s10 */
			set(register(s11), to: cc.savedS11)
			set(register(ra), to: cc.retcap)
			popScope
			return(to: register(ra, cap(code)))
		)
	)
)