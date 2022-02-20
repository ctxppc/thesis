(
	do(
		set(ls.arg0, to: constant(1))
		set(ls.arg1, to: constant(1))
		call(fib, location(ls.arg0) location(ls.arg1), result: df.result)
		return(location(df.result))
	),
	procedures: (
		fib,
		takes: (ls.first, s32()) (ls.second, s32()),
		returns: s32(),
		in: do(
			set(ls.arg0, to: constant(2))
			set(ls.arg1, to: constant(29))
			allocateVector(s32(), count: 30, into: ls.arg2)
			call(recFib, location(ls.arg0) location(ls.arg1) location(ls.arg2), result: df.result$1)
			return(location(df.result$1))
		)
	)
	(
		recFib,
		takes: (ls.index, s32()) (ls.lastIndex, s32()) (ls.nums, vectorCap(s32())),
		returns: s32(),
		in: if(
			do(
				set(ls.lhs, to: location(ls.index)) set(ls.rhs, to: location(ls.lastIndex)),
				then: relation(location(ls.lhs), gt, location(ls.rhs))
			),
			then: do(
				set(ls.vec, to: location(ls.nums))
				set(ls.idx, to: location(ls.lastIndex))
				getElement(of: ls.vec, index: location(ls.idx), to: df.result$2)
				return(location(df.result$2))
			),
			else: do(
				set(ls.lhs$1, to: location(ls.index))
				set(ls.rhs$1, to: constant(2))
				compute(location(ls.lhs$1), sub, location(ls.rhs$1), to: ls.indexOfFirst)
				set(ls.lhs$2, to: location(ls.index))
				set(ls.rhs$2, to: constant(1))
				compute(location(ls.lhs$2), sub, location(ls.rhs$2), to: ls.indexOfSecond)
				set(ls.lhs$3, to: location(ls.index))
				set(ls.rhs$3, to: constant(1))
				compute(location(ls.lhs$3), add, location(ls.rhs$3), to: ls.nextIndex)
				set(ls.vec$1, to: location(ls.nums))
				set(ls.idx$1, to: location(ls.indexOfFirst))
				getElement(of: ls.vec$1, index: location(ls.idx$1), to: ls.lhs$4)
				set(ls.vec$2, to: location(ls.nums))
				set(ls.idx$2, to: location(ls.indexOfSecond))
				getElement(of: ls.vec$2, index: location(ls.idx$2), to: ls.rhs$4)
				compute(location(ls.lhs$4), add, location(ls.rhs$4), to: ls.fibNum)
				set(ls.vec$3, to: location(ls.nums))
				set(ls.idx$3, to: location(ls.index))
				set(ls.elem, to: location(ls.fibNum))
				setElement(of: ls.vec$3, index: location(ls.idx$3), to: location(ls.elem))
				set(ls.arg0, to: location(ls.nextIndex))
				set(ls.arg1, to: location(ls.lastIndex))
				set(ls.arg2, to: location(ls.nums))
				call(recFib, location(ls.arg0) location(ls.arg1) location(ls.arg2), result: df.result$3)
				return(location(df.result$3))
			)
		)
	)
)