(
	locals: abstract(cc.retcap, cap) abstract(df.result, s32) abstract(ls.arg, s32) abstract(ls.arg$1, s32),
	in: do(
		pushScope
		set(abstract(cc.retcap), to: register(ra, cap))
		set(abstract(ls.arg), to: 0)
		set(abstract(ls.arg$1), to: 1)
		set(register(a0), to: ls.arg)
		set(register(a1), to: ls.arg$1)
		call(capability(to: fib), parameters: a0 a1)
		set(abstract(df.result), to: register(a0, s32))
		set(register(a0), to: df.result)
		set(register(ra), to: cc.retcap)
		popScope
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
		abstract(ls.arg, s32)
		abstract(ls.arg$1, s32)
		abstract(ls.arg$2, cap)
		abstract(ls.elem$1, s32)
		abstract(ls.elem$3, s32)
		abstract(ls.first, s32)
		abstract(ls.idx$1, s32)
		abstract(ls.idx$3, s32)
		abstract(ls.nums, cap)
		abstract(ls.second, s32)
		abstract(ls.vec$1, cap)
		abstract(ls.vec$3, cap)
		abstract(sv.offset, s32)
		abstract(sv.offset$1, s32),
		in: do(
			pushScope
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
			createBuffer(bytes: 120, capability: abstract(ls.nums), scoped: false)
			set(abstract(ls.vec$1), to: ls.nums)
			set(abstract(ls.idx$1), to: 0)
			set(abstract(ls.elem$1), to: ls.first)
			compute(abstract(sv.offset), ls.idx$1, sll, 2)
			setElement(s32, of: abstract(ls.vec$1), offset: sv.offset, to: ls.elem$1)
			set(abstract(ls.vec$3), to: ls.nums)
			set(abstract(ls.idx$3), to: 1)
			set(abstract(ls.elem$3), to: ls.second)
			compute(abstract(sv.offset$1), ls.idx$3, sll, 2)
			setElement(s32, of: abstract(ls.vec$3), offset: sv.offset$1, to: ls.elem$3)
			set(abstract(ls.arg), to: 2)
			set(abstract(ls.arg$1), to: 29)
			set(abstract(ls.arg$2), to: ls.nums)
			set(register(a0), to: ls.arg)
			set(register(a1), to: ls.arg$1)
			set(register(a2), to: ls.arg$2)
			call(capability(to: recFib), parameters: a0 a1 a2)
			set(abstract(df.result$1), to: register(a0, s32))
			set(register(a0), to: df.result$1)
			set(register(s1), to: cc.savedS1)
			set(register(s2), to: cc.savedS2)
			set(register(s3), to: cc.savedS3)
			set(register(s4), to: cc.savedS4)
			set(register(s5), to: cc.savedS5)
			set(register(s6), to: cc.savedS6)
			set(register(s7), to: cc.savedS7)
			set(register(s8), to: cc.savedS8)
			set(register(s9), to: cc.savedS9)
			set(register(s10), to: cc.savedS10)
			set(register(s11), to: cc.savedS11)
			set(register(ra), to: cc.retcap)
			popScope
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
		abstract(ls.arg, s32)
		abstract(ls.arg$1, s32)
		abstract(ls.arg$2, cap)
		abstract(ls.elem$1, s32)
		abstract(ls.idx, s32)
		abstract(ls.idx$2, s32)
		abstract(ls.idx$3, s32)
		abstract(ls.idx$4, s32)
		abstract(ls.index, s32)
		abstract(ls.lastIndex, s32)
		abstract(ls.lhs, s32)
		abstract(ls.lhs$1, s32)
		abstract(ls.lhs$2, s32)
		abstract(ls.lhs$3, s32)
		abstract(ls.lhs$4, s32)
		abstract(ls.nums, cap)
		abstract(ls.rhs, s32)
		abstract(ls.rhs$1, s32)
		abstract(ls.rhs$2, s32)
		abstract(ls.rhs$3, s32)
		abstract(ls.rhs$4, s32)
		abstract(ls.vec, cap)
		abstract(ls.vec$2, cap)
		abstract(ls.vec$3, cap)
		abstract(ls.vec$4, cap)
		abstract(sv.offset, s32)
		abstract(sv.offset$1, s32)
		abstract(sv.offset$2, s32)
		abstract(sv.offset$3, s32),
		in: do(
			pushScope
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
					set(abstract(ls.lhs), to: ls.index) set(abstract(ls.rhs), to: ls.lastIndex),
					then: relation(ls.lhs, gt, ls.rhs)
				),
				then: do(
					set(abstract(ls.vec), to: ls.nums)
					set(abstract(ls.idx), to: ls.lastIndex)
					compute(abstract(sv.offset), ls.idx, sll, 2)
					getElement(s32, of: abstract(ls.vec), offset: sv.offset, to: abstract(df.result$2))
					set(register(a0), to: df.result$2)
					set(register(s1), to: cc.savedS1)
					set(register(s2), to: cc.savedS2)
					set(register(s3), to: cc.savedS3)
					set(register(s4), to: cc.savedS4)
					set(register(s5), to: cc.savedS5)
					set(register(s6), to: cc.savedS6)
					set(register(s7), to: cc.savedS7)
					set(register(s8), to: cc.savedS8)
					set(register(s9), to: cc.savedS9)
					set(register(s10), to: cc.savedS10)
					set(register(s11), to: cc.savedS11)
					set(register(ra), to: cc.retcap)
					popScope
					return(to: register(ra, cap))
				),
				else: do(
					set(abstract(ls.vec$2), to: ls.nums)
					set(abstract(ls.idx$2), to: ls.index)
					set(abstract(ls.vec$3), to: ls.nums)
					set(abstract(ls.lhs$1), to: ls.index)
					set(abstract(ls.rhs$1), to: 2)
					compute(abstract(ls.idx$3), ls.lhs$1, sub, ls.rhs$1)
					compute(abstract(sv.offset$1), ls.idx$3, sll, 2)
					getElement(s32, of: abstract(ls.vec$3), offset: sv.offset$1, to: abstract(ls.lhs$2))
					set(abstract(ls.vec$4), to: ls.nums)
					set(abstract(ls.lhs$3), to: ls.index)
					set(abstract(ls.rhs$2), to: 1)
					compute(abstract(ls.idx$4), ls.lhs$3, sub, ls.rhs$2)
					compute(abstract(sv.offset$2), ls.idx$4, sll, 2)
					getElement(s32, of: abstract(ls.vec$4), offset: sv.offset$2, to: abstract(ls.rhs$3))
					compute(abstract(ls.elem$1), ls.lhs$2, add, ls.rhs$3)
					compute(abstract(sv.offset$3), ls.idx$2, sll, 2)
					setElement(s32, of: abstract(ls.vec$2), offset: sv.offset$3, to: ls.elem$1)
					set(abstract(ls.lhs$4), to: ls.index)
					set(abstract(ls.rhs$4), to: 1)
					compute(abstract(ls.arg), ls.lhs$4, add, ls.rhs$4)
					set(abstract(ls.arg$1), to: ls.lastIndex)
					set(abstract(ls.arg$2), to: ls.nums)
					set(register(a0), to: ls.arg)
					set(register(a1), to: ls.arg$1)
					set(register(a2), to: ls.arg$2)
					call(capability(to: recFib), parameters: a0 a1 a2)
					set(abstract(df.result$3), to: register(a0, s32))
					set(register(a0), to: df.result$3)
					set(register(s1), to: cc.savedS1)
					set(register(s2), to: cc.savedS2)
					set(register(s3), to: cc.savedS3)
					set(register(s4), to: cc.savedS4)
					set(register(s5), to: cc.savedS5)
					set(register(s6), to: cc.savedS6)
					set(register(s7), to: cc.savedS7)
					set(register(s8), to: cc.savedS8)
					set(register(s9), to: cc.savedS9)
					set(register(s10), to: cc.savedS10)
					set(register(s11), to: cc.savedS11)
					set(register(ra), to: cc.retcap)
					popScope
					return(to: register(ra, cap))
				)
			)
		)
	)
)