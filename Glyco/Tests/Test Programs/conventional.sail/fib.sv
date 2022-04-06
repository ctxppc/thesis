(
	do(
		pushScope()
		set(abstract(cc.retcap), to: register(ra, cap(code())))
		set(abstract(ls.arg0), to: constant(0))
		set(abstract(ls.arg1), to: constant(1))
		set(abstract(ls.arg2), to: constant(30))
		set(register(a0), to: abstract(ls.arg0))
		set(register(a1), to: abstract(ls.arg1))
		set(register(a2), to: abstract(ls.arg2))
		call(capability(to: fib), parameters: a0 a1 a2)
		set(abstract(df.result), to: register(a0, s32()))
		set(register(a0), to: abstract(df.result))
		set(register(ra), to: abstract(cc.retcap))
		popScope()
		return(to: register(ra, cap(code())))
	),
	procedures: (
		fib,
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
			set(abstract(ls.prev), to: register(a0, s32()))
			set(abstract(ls.curr), to: register(a1, s32()))
			set(abstract(ls.iter), to: register(a2, s32()))
			if(
				do(
					set(abstract(ls.lhs), to: abstract(ls.iter)) set(abstract(ls.rhs), to: constant(1)),
					then: relation(abstract(ls.lhs), le, abstract(ls.rhs))
				),
				then: do(
					set(abstract(df.result$1), to: abstract(ls.curr))
					set(register(a0), to: abstract(df.result$1))
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
				),
				else: do(
					set(abstract(ls.arg0), to: abstract(ls.curr))
					set(abstract(ls.lhs$1), to: abstract(ls.prev))
					set(abstract(ls.rhs$1), to: abstract(ls.curr))
					compute(abstract(ls.arg1), abstract(ls.lhs$1), add, abstract(ls.rhs$1))
					set(abstract(ls.lhs$2), to: abstract(ls.iter))
					set(abstract(ls.rhs$2), to: constant(1))
					compute(abstract(ls.arg2), abstract(ls.lhs$2), sub, abstract(ls.rhs$2))
					set(register(a0), to: abstract(ls.arg0))
					set(register(a1), to: abstract(ls.arg1))
					set(register(a2), to: abstract(ls.arg2))
					call(capability(to: fib), parameters: a0 a1 a2)
					set(abstract(df.result$2), to: register(a0, s32()))
					set(register(a0), to: abstract(df.result$2))
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
	)
)