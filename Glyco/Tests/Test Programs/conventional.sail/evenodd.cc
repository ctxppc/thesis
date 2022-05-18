(
	do(
		set(ls.even, to: procedure(l.even))
		set(ls.odd, to: procedure(l.odd))
		set(ls.arg, to: 246)
		set(ls.f, to: ls.even)
		call(ls.f, ls.arg, result: df.result)
		return(df.result)
	),
	procedures: (
		l.even,
		takes: (ls.n, s32),
		returns: s32,
		in: do(
			set(ls.even, to: procedure(l.even))
			set(ls.odd, to: procedure(l.odd))
			if(
				do(set(ls.lhs, to: ls.n) set(ls.rhs, to: 0), then: relation(ls.lhs, le, ls.rhs)),
				then: do(set(df.result$1, to: 1) return(df.result$1)),
				else: do(
					set(ls.lhs$1, to: ls.n)
					set(ls.rhs$1, to: 1)
					compute(ls.arg, ls.lhs$1, sub, ls.rhs$1)
					set(ls.f, to: ls.odd)
					call(ls.f, ls.arg, result: df.result$2)
					return(df.result$2)
				)
			)
		)
	)
	(
		l.odd,
		takes: (ls.n, s32),
		returns: s32,
		in: do(
			set(ls.even, to: procedure(l.even))
			set(ls.odd, to: procedure(l.odd))
			if(
				do(set(ls.lhs, to: ls.n) set(ls.rhs, to: 0), then: relation(ls.lhs, le, ls.rhs)),
				then: do(set(df.result$3, to: 0) return(df.result$3)),
				else: do(
					set(ls.lhs$1, to: ls.n)
					set(ls.rhs$1, to: 1)
					compute(ls.arg, ls.lhs$1, sub, ls.rhs$1)
					set(ls.f, to: ls.even)
					call(ls.f, ls.arg, result: df.result$4)
					return(df.result$4)
				)
			)
		)
	)
)