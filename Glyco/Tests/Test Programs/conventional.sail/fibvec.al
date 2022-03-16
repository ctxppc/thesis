(
	locals: abstract(cc.retcap, cap) abstract(df.result, s32) abstract(ls.arg0, s32) abstract(ls.arg1, s32),
	in: do(
		pushScope()
		set(abstract(cc.retcap), to: register(ra, cap))
		set(abstract(ls.arg0), to: constant(1))
		set(abstract(ls.arg1), to: constant(1))
		set(register(a0), to: abstract(ls.arg0))
		set(register(a1), to: abstract(ls.arg1))
		call(fib, parameters: a0 a1)
		set(abstract(df.result), to: register(a0, s32))
		set(register(a0), to: abstract(df.result))
		set(register(ra), to: abstract(cc.retcap))
		popScope()
		return(to: register(ra, cap))
	),
	procedures: (
		fib,
		locals: abstract(cc.retcap, cap)
		abstract(cc.savedS1, cap)
		abstract(cc.savedS10, cap)
		abstract(cc.savedS11, cap)
		abstract(cc.savedS2, cap)
		abstract(cc.savedS3, cap)
		abstract(cc.savedS4, cap)
		abstract(cc.savedS5, cap)
		abstract(cc.savedS6, cap)
		abstract(cc.savedS7, cap)
		abstract(cc.savedS8, cap)
		abstract(cc.savedS9, cap)
		abstract(df.result$1, s32)
		abstract(ls.arg0, s32)
		abstract(ls.arg1, s32)
		abstract(ls.arg2, cap)
		abstract(ls.first, s32)
		abstract(ls.second, s32),
		in: do(
			pushScope()
			set(abstract(cc.savedS1), to: register(s1, cap))
			set(abstract(cc.savedS2), to: register(s2, cap))
			set(abstract(cc.savedS3), to: register(s3, cap))
			set(abstract(cc.savedS4), to: register(s4, cap))
			set(abstract(cc.savedS5), to: register(s5, cap))
			set(abstract(cc.savedS6), to: register(s6, cap))
			set(abstract(cc.savedS7), to: register(s7, cap))
			set(abstract(cc.savedS8), to: register(s8, cap))
			set(abstract(cc.savedS9), to: register(s9, cap))
			set(abstract(cc.savedS10), to: register(s10, cap))
			set(abstract(cc.savedS11), to: register(s11, cap))
			set(abstract(cc.retcap), to: register(ra, cap))
			set(abstract(ls.first), to: register(a0, s32))
			set(abstract(ls.second), to: register(a1, s32))
			set(abstract(ls.arg0), to: constant(2))
			set(abstract(ls.arg1), to: constant(29))
			createBuffer(bytes: 120, capability: abstract(ls.arg2), scoped: true)
			set(register(a0), to: abstract(ls.arg0))
			set(register(a1), to: abstract(ls.arg1))
			set(register(a2), to: abstract(ls.arg2))
			call(recFib, parameters: a0 a1 a2)
			set(abstract(df.result$1), to: register(a0, s32))
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
			return(to: register(ra, cap))
		)
	)
	(
		recFib,
		locals: abstract(cc.retcap, cap)
		abstract(cc.savedS1, cap)
		abstract(cc.savedS10, cap)
		abstract(cc.savedS11, cap)
		abstract(cc.savedS2, cap)
		abstract(cc.savedS3, cap)
		abstract(cc.savedS4, cap)
		abstract(cc.savedS5, cap)
		abstract(cc.savedS6, cap)
		abstract(cc.savedS7, cap)
		abstract(cc.savedS8, cap)
		abstract(cc.savedS9, cap)
		abstract(df.result$2, s32)
		abstract(df.result$3, s32)
		abstract(ls.arg0, s32)
		abstract(ls.arg1, s32)
		abstract(ls.arg2, cap)
		abstract(ls.elem, s32)
		abstract(ls.fibNum, s32)
		abstract(ls.idx, s32)
		abstract(ls.idx$1, s32)
		abstract(ls.idx$2, s32)
		abstract(ls.idx$3, s32)
		abstract(ls.index, s32)
		abstract(ls.indexOfFirst, s32)
		abstract(ls.indexOfSecond, s32)
		abstract(ls.lastIndex, s32)
		abstract(ls.lhs, s32)
		abstract(ls.lhs$1, s32)
		abstract(ls.lhs$2, s32)
		abstract(ls.lhs$3, s32)
		abstract(ls.lhs$4, s32)
		abstract(ls.nextIndex, s32)
		abstract(ls.nums, cap)
		abstract(ls.rhs, s32)
		abstract(ls.rhs$1, s32)
		abstract(ls.rhs$2, s32)
		abstract(ls.rhs$3, s32)
		abstract(ls.rhs$4, s32)
		abstract(ls.vec, cap)
		abstract(ls.vec$1, cap)
		abstract(ls.vec$2, cap)
		abstract(ls.vec$3, cap)
		abstract(sv.offset, s32)
		abstract(sv.offset$1, s32)
		abstract(sv.offset$2, s32)
		abstract(sv.offset$3, s32),
		in: do(
			pushScope()
			set(abstract(cc.savedS1), to: register(s1, cap))
			set(abstract(cc.savedS2), to: register(s2, cap))
			set(abstract(cc.savedS3), to: register(s3, cap))
			set(abstract(cc.savedS4), to: register(s4, cap))
			set(abstract(cc.savedS5), to: register(s5, cap))
			set(abstract(cc.savedS6), to: register(s6, cap))
			set(abstract(cc.savedS7), to: register(s7, cap))
			set(abstract(cc.savedS8), to: register(s8, cap))
			set(abstract(cc.savedS9), to: register(s9, cap))
			set(abstract(cc.savedS10), to: register(s10, cap))
			set(abstract(cc.savedS11), to: register(s11, cap))
			set(abstract(cc.retcap), to: register(ra, cap))
			set(abstract(ls.index), to: register(a0, s32))
			set(abstract(ls.lastIndex), to: register(a1, s32))
			set(abstract(ls.nums), to: register(a2, cap))
			if(
				do(
					set(abstract(ls.lhs), to: abstract(ls.index)) set(abstract(ls.rhs), to: abstract(ls.lastIndex)),
					then: relation(abstract(ls.lhs), gt, abstract(ls.rhs))
				),
				then: do(
					set(abstract(ls.vec), to: abstract(ls.nums))
					set(abstract(ls.idx), to: abstract(ls.lastIndex))
					compute(abstract(sv.offset), abstract(ls.idx), sll, constant(2))
					getElement(s32, of: abstract(ls.vec), offset: abstract(sv.offset), to: abstract(df.result$2))
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
					return(to: register(ra, cap))
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
					compute(abstract(sv.offset$1), abstract(ls.idx$1), sll, constant(2))
					getElement(s32, of: abstract(ls.vec$1), offset: abstract(sv.offset$1), to: abstract(ls.lhs$4))
					set(abstract(ls.vec$2), to: abstract(ls.nums))
					set(abstract(ls.idx$2), to: abstract(ls.indexOfSecond))
					compute(abstract(sv.offset$2), abstract(ls.idx$2), sll, constant(2))
					getElement(s32, of: abstract(ls.vec$2), offset: abstract(sv.offset$2), to: abstract(ls.rhs$4))
					compute(abstract(ls.fibNum), abstract(ls.lhs$4), add, abstract(ls.rhs$4))
					set(abstract(ls.vec$3), to: abstract(ls.nums))
					set(abstract(ls.idx$3), to: abstract(ls.index))
					set(abstract(ls.elem), to: abstract(ls.fibNum))
					compute(abstract(sv.offset$3), abstract(ls.idx$3), sll, constant(2))
					setElement(s32, of: abstract(ls.vec$3), offset: abstract(sv.offset$3), to: abstract(ls.elem))
					set(abstract(ls.arg0), to: abstract(ls.nextIndex))
					set(abstract(ls.arg1), to: abstract(ls.lastIndex))
					set(abstract(ls.arg2), to: abstract(ls.nums))
					set(register(a0), to: abstract(ls.arg0))
					set(register(a1), to: abstract(ls.arg1))
					set(register(a2), to: abstract(ls.arg2))
					call(recFib, parameters: a0 a1 a2)
					set(abstract(df.result$3), to: register(a0, s32))
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
					return(to: register(ra, cap))
				)
			)
		)
	)
)