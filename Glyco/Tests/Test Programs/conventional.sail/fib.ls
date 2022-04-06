(
	let(
		(ex.arg, source(constant(0))) (ex.arg$1, source(constant(1))) (ex.arg$2, source(constant(30))),
		in: evaluate(function(fib), named(ex.arg) named(ex.arg$1) named(ex.arg$2))
	),
	functions: (
		fib,
		takes: (prev, s32()) (curr, s32()) (iter, s32()),
		returns: s32(),
		in: if(
			let((ex.lhs, source(named(iter))) (ex.rhs, source(constant(1))), in: relation(named(ex.lhs), le, named(ex.rhs))),
			then: value(source(named(curr))),
			else: let(
				(ex.arg$3, source(named(curr)))
				(
					ex.arg$4,
					let(
						(ex.lhs$1, source(named(prev))) (ex.rhs$1, source(named(curr))),
						in: binary(named(ex.lhs$1), add, named(ex.rhs$1))
					)
				)
				(
					ex.arg$5,
					let(
						(ex.lhs$2, source(named(iter))) (ex.rhs$2, source(constant(1))),
						in: binary(named(ex.lhs$2), sub, named(ex.rhs$2))
					)
				),
				in: evaluate(function(fib), named(ex.arg$3) named(ex.arg$4) named(ex.arg$5))
			)
		)
	)
)