(
	do(
		set(ls.arg0, to: constant(0))
		set(ls.arg1, to: constant(1))
		set(ls.arg2, to: constant(30))
		call(fib, location(ls.arg0) location(ls.arg1) location(ls.arg2), result: df.result)
		return(location(df.result))
	),
	procedures: (
		fib,
		takes: (ls.prev, s32()) (ls.curr, s32()) (ls.iter, s32()),
		returns: s32(),
		in: if(
			do(
				set(ls.lhs, to: location(ls.iter)) set(ls.rhs, to: constant(0)),
				then: relation(location(ls.lhs), le, location(ls.rhs))
			),
			then: do(set(df.result$1, to: location(ls.curr)) return(location(df.result$1))),
			else: do(
				set(ls.arg0, to: location(ls.curr))
				set(ls.lhs$1, to: location(ls.prev))
				set(ls.rhs$1, to: location(ls.curr))
				compute(ls.arg1, location(ls.lhs$1), add, location(ls.rhs$1))
				set(ls.lhs$2, to: location(ls.iter))
				set(ls.rhs$2, to: constant(1))
				compute(ls.arg2, location(ls.lhs$2), sub, location(ls.rhs$2))
				call(fib, location(ls.arg0) location(ls.arg1) location(ls.arg2), result: df.result$2)
				return(location(df.result$2))
			)
		)
	)
)