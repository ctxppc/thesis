(
	do(
		pushScope()
		set(abstract(cc.retcap), to: register(ra, cap(code())))
		set(abstract(ls.arg0), to: constant(1))
		set(abstract(ls.arg1), to: constant(1))
		set(register(a0), to: abstract(ls.arg0))
		set(register(a1), to: abstract(ls.arg1))
		call(fib, parameters: a0 a1)
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
			set(abstract(ls.first), to: register(a0, s32()))
			set(abstract(ls.second), to: register(a1, s32()))
			set(abstract(ls.arg0), to: constant(2))
			set(abstract(ls.arg1), to: constant(29))
			createVector(s32(), count: 30, capability: abstract(ls.arg2), scoped: true)
			set(register(a0), to: abstract(ls.arg0))
			set(register(a1), to: abstract(ls.arg1))
			set(register(a2), to: abstract(ls.arg2))
			call(recFib, parameters: a0 a1 a2)
			set(abstract(df.result$1), to: register(a0, s32()))
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
		)
	)
	(
		recFib,
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
			set(abstract(ls.index), to: register(a0, s32()))
			set(abstract(ls.lastIndex), to: register(a1, s32()))
			set(abstract(ls.nums), to: register(a2, cap(vector(of: s32(), sealed: false))))
			if(
				do(
					set(abstract(ls.lhs), to: abstract(ls.index)) set(abstract(ls.rhs), to: abstract(ls.lastIndex)),
					then: relation(abstract(ls.lhs), gt, abstract(ls.rhs))
				),
				then: do(
					set(abstract(ls.vec), to: abstract(ls.nums))
					set(abstract(ls.idx), to: abstract(ls.lastIndex))
					getElement(of: abstract(ls.vec), index: abstract(ls.idx), to: abstract(df.result$2))
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
				),
				else: do(
					set(abstract(ls.lhs$1), to: abstract(ls.index))
					set(abstract(ls.rhs$1), to: constant(2))
					compute(abstract(ls.indexOfFirst), abstract(ls.lhs$1), sub, abstract(ls.rhs$1))
					set(abstract(ls.lhs$2), to: abstract(ls.index))
					set(abstract(ls.rhs$2), to: constant(1))
					compute(abstract(ls.indexOfSecond), abstract(ls.lhs$2), sub, abstract(ls.rhs$2))
					set(abstract(ls.lhs$3), to: abstract(ls.index))
					set(abstract(ls.rhs$3), to: constant(1))
					compute(abstract(ls.nextIndex), abstract(ls.lhs$3), add, abstract(ls.rhs$3))
					set(abstract(ls.vec$1), to: abstract(ls.nums))
					set(abstract(ls.idx$1), to: abstract(ls.indexOfFirst))
					getElement(of: abstract(ls.vec$1), index: abstract(ls.idx$1), to: abstract(ls.lhs$4))
					set(abstract(ls.vec$2), to: abstract(ls.nums))
					set(abstract(ls.idx$2), to: abstract(ls.indexOfSecond))
					getElement(of: abstract(ls.vec$2), index: abstract(ls.idx$2), to: abstract(ls.rhs$4))
					compute(abstract(ls.fibNum), abstract(ls.lhs$4), add, abstract(ls.rhs$4))
					set(abstract(ls.vec$3), to: abstract(ls.nums))
					set(abstract(ls.idx$3), to: abstract(ls.index))
					set(abstract(ls.elem), to: abstract(ls.fibNum))
					setElement(of: abstract(ls.vec$3), index: abstract(ls.idx$3), to: abstract(ls.elem))
					set(abstract(ls.arg0), to: abstract(ls.nextIndex))
					set(abstract(ls.arg1), to: abstract(ls.lastIndex))
					set(abstract(ls.arg2), to: abstract(ls.nums))
					set(register(a0), to: abstract(ls.arg0))
					set(register(a1), to: abstract(ls.arg1))
					set(register(a2), to: abstract(ls.arg2))
					call(recFib, parameters: a0 a1 a2)
					set(abstract(df.result$3), to: register(a0, s32()))
					set(register(a0), to: abstract(df.result$3))
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