(
	do(
		set(ls.arg, to: constant(1080))
		set(ls.arg$1, to: constant(-80))
		call(procedure(l.anon), location(ls.arg) location(ls.arg$1), result: df.result)
		return(location(df.result))
	),
	procedures: (
		l.anon,
		takes: (ls.first, s32(), sealed: false) (ls.second, s32(), sealed: false),
		returns: s32(),
		in: do(
			set(ls.lhs, to: location(ls.first))
			set(ls.rhs, to: location(ls.second))
			compute(df.result$1, location(ls.lhs), add, location(ls.rhs))
			return(location(df.result$1))
		)
	)
)