(
	do(set(ls.arg, to: 1080) set(ls.arg$1, to: -80) call(procedure(l.anon), ls.arg ls.arg$1, result: df.result) return(df.result)),
	procedures: (
		l.anon,
		takes: (ls.first, s32, sealed: false) (ls.second, s32, sealed: false),
		returns: s32,
		in: do(set(ls.lhs, to: ls.first) set(ls.rhs, to: ls.second) compute(df.result$1, ls.lhs, add, ls.rhs) return(df.result$1))
	)
)