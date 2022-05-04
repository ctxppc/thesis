(
	do(
		set(ls.arg, to: 0)
		set(ls.arg$1, to: 1)
		set(ls.arg$2, to: 30)
		call(procedure(fib), ls.arg ls.arg$1 ls.arg$2, result: df.result)
		return(df.result)
	),
	procedures: (
		fib,
		takes: (ls.prev, s32, sealed: false) (ls.curr, s32, sealed: false) (ls.iter, s32, sealed: false),
		returns: s32,
		in: if(
			do(set(ls.lhs, to: ls.iter) set(ls.rhs, to: 1), then: relation(ls.lhs, le, ls.rhs)),
			then: do(set(df.result$1, to: ls.curr) return(df.result$1)),
			else: do(
				set(ls.arg, to: ls.curr)
				set(ls.lhs$1, to: ls.prev)
				set(ls.rhs$1, to: ls.curr)
				compute(ls.arg$1, ls.lhs$1, add, ls.rhs$1)
				set(ls.lhs$2, to: ls.iter)
				set(ls.rhs$2, to: 1)
				compute(ls.arg$2, ls.lhs$2, sub, ls.rhs$2)
				call(procedure(fib), ls.arg ls.arg$1 ls.arg$2, result: df.result$2)
				return(df.result$2)
			)
		)
	)
)