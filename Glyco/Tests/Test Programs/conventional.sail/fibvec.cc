(
	do(
		set(ls.arg, to: constant(0))
		set(ls.arg$1, to: constant(1))
		call(procedure(fib), location(ls.arg) location(ls.arg$1), result: df.result)
		return(location(df.result))
	),
	procedures: (
		fib,
		takes: (ls.first, s32(), sealed: false) (ls.second, s32(), sealed: false),
		returns: s32(),
		in: do(
			set(ls.arg, to: constant(2))
			set(ls.arg$1, to: constant(29))
			createVector(s32(), count: 30, capability: ls.arg$2, scoped: true)
			call(procedure(recFib), location(ls.arg) location(ls.arg$1) location(ls.arg$2), result: df.result$1)
			return(location(df.result$1))
		)
	)
	(
		recFib,
		takes: (ls.index, s32(), sealed: false)
		(ls.lastIndex, s32(), sealed: false)
		(ls.nums, cap(vector(of: s32(), sealed: false)), sealed: false),
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
				set(ls.vec$1, to: location(ls.nums))
				set(ls.idx$1, to: location(ls.index))
				set(ls.vec$2, to: location(ls.nums))
				set(ls.lhs$2, to: location(ls.index))
				set(ls.rhs$2, to: constant(2))
				compute(ls.idx$2, location(ls.lhs$2), sub, location(ls.rhs$2))
				getElement(of: ls.vec$2, index: location(ls.idx$2), to: ls.lhs$1)
				set(ls.vec$3, to: location(ls.nums))
				set(ls.lhs$3, to: location(ls.index))
				set(ls.rhs$3, to: constant(1))
				compute(ls.idx$3, location(ls.lhs$3), sub, location(ls.rhs$3))
				getElement(of: ls.vec$3, index: location(ls.idx$3), to: ls.rhs$1)
				compute(ls.elem, location(ls.lhs$1), add, location(ls.rhs$1))
				setElement(of: ls.vec$1, index: location(ls.idx$1), to: location(ls.elem))
				set(ls.lhs$4, to: location(ls.index))
				set(ls.rhs$4, to: constant(1))
				compute(ls.arg, location(ls.lhs$4), add, location(ls.rhs$4))
				set(ls.arg$1, to: location(ls.lastIndex))
				set(ls.arg$2, to: location(ls.nums))
				call(procedure(recFib), location(ls.arg) location(ls.arg$1) location(ls.arg$2), result: df.result$3)
				return(location(df.result$3))
			)
		)
	)
)