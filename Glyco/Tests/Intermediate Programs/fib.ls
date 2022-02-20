(
	let(
		(arg0, source(constant(0))) (arg1, source(constant(1))) (arg2, source(constant(30))),
		in: evaluate(fib, named(arg0) named(arg1) named(arg2))
	),
	functions: (
		fib,
		takes: (prev, s32()) (curr, s32()) (iter, s32()),
		returns: s32(),
		in: if(
			let((ex.lhs, source(named(iter))) (ex.rhs, source(constant(0))), in: relation(named(ex.lhs), le, named(ex.rhs))),
			then: value(source(named(curr))),
			else: let(
				(arg0, source(named(curr)))
				(
					arg1,
					let(
						(ex.lhs$1, source(named(prev))) (ex.rhs$1, source(named(curr))),
						in: binary(named(ex.lhs$1), add, named(ex.rhs$1))
					)
				)
				(
					arg2,
					let(
						(ex.lhs$2, source(named(iter))) (ex.rhs$2, source(constant(1))),
						in: binary(named(ex.lhs$2), sub, named(ex.rhs$2))
					)
				),
				in: evaluate(fib, named(arg0) named(arg1) named(arg2))
			)
		)
	)
)