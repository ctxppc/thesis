(
	do(set(ls.arg, to: 0) set(ls.arg$1, to: 1) call(procedure(fib), ls.arg ls.arg$1, result: df.result) return(df.result)),
	procedures: (
		fib,
		takes: (ls.first, s32) (ls.second, s32),
		returns: s32,
		in: do(
			createVector(s32, count: 30, capability: ls.nums, scoped: false)
			set(ls.vec$1, to: ls.nums)
			set(ls.idx$1, to: 0)
			set(ls.elem$1, to: ls.first)
			setElement(of: ls.vec$1, index: ls.idx$1, to: ls.elem$1)
			set(ls.vec$3, to: ls.nums)
			set(ls.idx$3, to: 1)
			set(ls.elem$3, to: ls.second)
			setElement(of: ls.vec$3, index: ls.idx$3, to: ls.elem$3)
			set(ls.arg, to: 2)
			set(ls.arg$1, to: 29)
			set(ls.arg$2, to: ls.nums)
			call(procedure(recFib), ls.arg ls.arg$1 ls.arg$2, result: df.result$1)
			return(df.result$1)
		)
	)
	(
		recFib,
		takes: (ls.index, s32) (ls.lastIndex, s32) (ls.nums, cap(vector(of: s32, sealed: false))),
		returns: s32,
		in: if(
			do(set(ls.lhs, to: ls.index) set(ls.rhs, to: ls.lastIndex), then: relation(ls.lhs, gt, ls.rhs)),
			then: do(
				set(ls.vec, to: ls.nums)
				set(ls.idx, to: ls.lastIndex)
				getElement(of: ls.vec, index: ls.idx, to: df.result$2)
				return(df.result$2)
			),
			else: do(
				set(ls.vec$2, to: ls.nums)
				set(ls.idx$2, to: ls.index)
				set(ls.vec$3, to: ls.nums)
				set(ls.lhs$1, to: ls.index)
				set(ls.rhs$1, to: 2)
				compute(ls.idx$3, ls.lhs$1, sub, ls.rhs$1)
				getElement(of: ls.vec$3, index: ls.idx$3, to: ls.lhs$2)
				set(ls.vec$4, to: ls.nums)
				set(ls.lhs$3, to: ls.index)
				set(ls.rhs$2, to: 1)
				compute(ls.idx$4, ls.lhs$3, sub, ls.rhs$2)
				getElement(of: ls.vec$4, index: ls.idx$4, to: ls.rhs$3)
				compute(ls.elem$1, ls.lhs$2, add, ls.rhs$3)
				setElement(of: ls.vec$2, index: ls.idx$2, to: ls.elem$1)
				set(ls.lhs$4, to: ls.index)
				set(ls.rhs$4, to: 1)
				compute(ls.arg, ls.lhs$4, add, ls.rhs$4)
				set(ls.arg$1, to: ls.lastIndex)
				set(ls.arg$2, to: ls.nums)
				call(procedure(recFib), ls.arg ls.arg$1 ls.arg$2, result: df.result$3)
				return(df.result$3)
			)
		)
	)
)