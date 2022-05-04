(
	let((ex.arg, source(0)) (ex.arg$1, source(1)) (ex.arg$2, source(30)), in: evaluate(function(fib), ex.arg ex.arg$1 ex.arg$2)),
	functions: (
		fib,
		takes: (prev, s32, sealed: false) (curr, s32, sealed: false) (iter, s32, sealed: false),
		returns: s32,
		in: if(
			let((ex.lhs, source(iter)) (ex.rhs, source(1)), in: relation(ex.lhs, le, ex.rhs)),
			then: value(source(curr)),
			else: let(
				(ex.arg$3, source(curr))
				(ex.arg$4, let((ex.lhs$1, source(prev)) (ex.rhs$1, source(curr)), in: binary(ex.lhs$1, add, ex.rhs$1)))
				(ex.arg$5, let((ex.lhs$2, source(iter)) (ex.rhs$2, source(1)), in: binary(ex.lhs$2, sub, ex.rhs$2))),
				in: evaluate(function(fib), ex.arg$3 ex.arg$4 ex.arg$5)
			)
		)
	)
)