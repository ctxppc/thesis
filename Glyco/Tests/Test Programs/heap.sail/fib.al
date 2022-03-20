(
	locals: abstract(cc.retcap, cap)
	abstract(df.result, s32)
	abstract(ls.arg0, s32)
	abstract(ls.arg1, s32)
	abstract(ls.arg2, s32),
	in: do(
		pushScope()
		set(abstract(cc.retcap), to: register(ra, cap))
		set(abstract(ls.arg0), to: constant(0))
		set(abstract(ls.arg1), to: constant(1))
		set(abstract(ls.arg2), to: constant(30))
		set(register(a0), to: abstract(ls.arg0))
		set(register(a1), to: abstract(ls.arg1))
		set(register(a2), to: abstract(ls.arg2))
		clearAll(except: a0 a1 a2)
		call(fib, parameters: a0 a1 a2)
		set(abstract(df.result), to: register(a0, s32))
		set(register(a0), to: abstract(df.result))
		set(register(ra), to: abstract(cc.retcap))
		clearAll(except: a0 ra)
		popScope()
		return(to: register(ra, cap))
	),
	procedures: (
		fib,
		locals: abstract(cc.retcap, cap)
		abstract(df.result$1, s32)
		abstract(df.result$2, s32)
		abstract(ls.arg0, s32)
		abstract(ls.arg1, s32)
		abstract(ls.arg2, s32)
		abstract(ls.curr, s32)
		abstract(ls.iter, s32)
		abstract(ls.lhs, s32)
		abstract(ls.lhs$1, s32)
		abstract(ls.lhs$2, s32)
		abstract(ls.prev, s32)
		abstract(ls.rhs, s32)
		abstract(ls.rhs$1, s32)
		abstract(ls.rhs$2, s32),
		in: do(
			pushScope()
			set(abstract(cc.retcap), to: register(ra, cap))
			set(abstract(ls.prev), to: register(a0, s32))
			set(abstract(ls.curr), to: register(a1, s32))
			set(abstract(ls.iter), to: register(a2, s32))
			if(
				do(
					set(abstract(ls.lhs), to: abstract(ls.iter)) set(abstract(ls.rhs), to: constant(0)),
					then: relation(abstract(ls.lhs), le, abstract(ls.rhs))
				),
				then: do(
					set(abstract(df.result$1), to: abstract(ls.curr))
					set(register(a0), to: abstract(df.result$1))
					set(register(ra), to: abstract(cc.retcap))
					clearAll(except: a0 ra)
					popScope()
					return(to: register(ra, cap))
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
					clearAll(except: a0 a1 a2)
					call(fib, parameters: a0 a1 a2)
					set(abstract(df.result$2), to: register(a0, s32))
					set(register(a0), to: abstract(df.result$2))
					set(register(ra), to: abstract(cc.retcap))
					clearAll(except: a0 ra)
					popScope()
					return(to: register(ra, cap))
				)
			)
		)
	)
)