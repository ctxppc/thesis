(
	let((arg0, source(constant(1))) (arg1, source(constant(1))), in: evaluate(fib, named(arg0) named(arg1))),
	functions: (
		fib,
		takes: (first, s32()) (second, s32()),
		returns: s32(),
		in: let(
			(arg0, source(constant(2))) (arg1, source(constant(29))) (arg2, vector(s32(), count: 30)),
			in: evaluate(recFib, named(arg0) named(arg1) named(arg2))
		)
	)
	(
		recFib,
		takes: (index, s32()) (lastIndex, s32()) (nums, cap(vector(of: s32(), sealed: false))),
		returns: s32(),
		in: if(
			let(
				(ex.lhs, source(named(index))) (ex.rhs, source(named(lastIndex))),
				in: relation(named(ex.lhs), gt, named(ex.rhs))
			),
			then: value(
				let((ex.vec, source(named(nums))) (ex.idx, source(named(lastIndex))), in: element(of: ex.vec, at: named(ex.idx)))
			),
			else: let(
				(
					indexOfFirst,
					let(
						(ex.lhs$1, source(named(index))) (ex.rhs$1, source(constant(2))),
						in: binary(named(ex.lhs$1), sub, named(ex.rhs$1))
					)
				)
				(
					indexOfSecond,
					let(
						(ex.lhs$2, source(named(index))) (ex.rhs$2, source(constant(1))),
						in: binary(named(ex.lhs$2), sub, named(ex.rhs$2))
					)
				)
				(
					nextIndex,
					let(
						(ex.lhs$3, source(named(index))) (ex.rhs$3, source(constant(1))),
						in: binary(named(ex.lhs$3), add, named(ex.rhs$3))
					)
				)
				(
					fibNum,
					let(
						(
							ex.lhs$4,
							let(
								(ex.vec$1, source(named(nums))) (ex.idx$1, source(named(indexOfFirst))),
								in: element(of: ex.vec$1, at: named(ex.idx$1))
							)
						)
						(
							ex.rhs$4,
							let(
								(ex.vec$2, source(named(nums))) (ex.idx$2, source(named(indexOfSecond))),
								in: element(of: ex.vec$2, at: named(ex.idx$2))
							)
						),
						in: binary(named(ex.lhs$4), add, named(ex.rhs$4))
					)
				),
				in: do(
					let(
						(ex.vec$3, source(named(nums))) (ex.idx$3, source(named(index))) (ex.elem, source(named(fibNum))),
						in: setElement(of: ex.vec$3, at: named(ex.idx$3), to: named(ex.elem))
					),
					then: let(
						(arg0, source(named(nextIndex))) (arg1, source(named(lastIndex))) (arg2, source(named(nums))),
						in: evaluate(recFib, named(arg0) named(arg1) named(arg2))
					)
				)
			)
		)
	)
)