(
	do(
		pushScope()
		set(abstract(cc.retcap), to: register(ra, cap(code())))
		set(register(a0), to: constant(19))
		set(register(a1), to: constant(23))
		call(sum, parameters: a0 a1)
		set(abstract(the_sum), to: register(a0, s32()))
		set(register(a0), to: abstract(the_sum))
		set(register(ra), to: abstract(cc.retcap))
		popScope()
		return(to: register(ra, cap(code())))
	),
	procedures: (
		sum,
		in: do(
			pushScope()
			set(abstract(cc.savedS1), to: register(s1, registerDatum()))
			set(abstract(cc.savedS2), to: register(s2, registerDatum()))
			set(abstract(cc.savedS3), to: register(s3, registerDatum()))
			set(abstract(cc.savedS4), to: register(s4, registerDatum()))
			set(abstract(cc.savedS5), to: register(s5, registerDatum()))
			set(abstract(cc.savedS6), to: register(s6, registerDatum()))
			set(abstract(cc.savedS7), to: register(s7, registerDatum()))
			set(abstract(cc.savedS8), to: register(s8, registerDatum()))
			set(abstract(cc.savedS9), to: register(s9, registerDatum()))
			set(abstract(cc.savedS10), to: register(s10, registerDatum()))
			set(abstract(cc.savedS11), to: register(s11, registerDatum()))
			set(abstract(cc.retcap), to: register(ra, cap(code())))
			set(abstract(first), to: register(a0, s32()))
			set(abstract(second), to: register(a1, s32()))
			compute(abstract(the_result), abstract(first), add, abstract(second))
			set(register(a0), to: abstract(the_result))
			set(register(s1), to: abstract(cc.savedS1))
			set(register(s2), to: abstract(cc.savedS2))
			set(register(s3), to: abstract(cc.savedS3))
			set(register(s4), to: abstract(cc.savedS4))
			set(register(s5), to: abstract(cc.savedS5))
			set(register(s6), to: abstract(cc.savedS6))
			set(register(s7), to: abstract(cc.savedS7))
			set(register(s8), to: abstract(cc.savedS8))
			set(register(s9), to: abstract(cc.savedS9))
			set(register(s10), to: abstract(cc.savedS10))
			set(register(s11), to: abstract(cc.savedS11))
			set(register(ra), to: abstract(cc.retcap))
			popScope()
			return(to: register(ra, cap(code())))
		)
	)
)