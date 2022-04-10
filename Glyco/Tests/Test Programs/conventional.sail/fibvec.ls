(
	let((ex.arg, source(constant(0))) (ex.arg$1, source(constant(1))), in: evaluate(function(fib), named(ex.arg) named(ex.arg$1))),
	functions: (
		fib,
		takes: (first, s32(), sealed: false) (second, s32(), sealed: false),
		returns: s32(),
		in: let(
			(ex.arg$2, source(constant(2))) (ex.arg$3, source(constant(29))) (ex.arg$4, vector(s32(), count: 30)),
			in: evaluate(function(recFib), named(ex.arg$2) named(ex.arg$3) named(ex.arg$4))
		)
	)
	(
		recFib,
		takes: (index, s32(), sealed: false)
		(lastIndex, s32(), sealed: false)
		(nums, cap(vector(of: s32(), sealed: false)), sealed: false),
		returns: s32(),
		in: if(
			let(
				(ex.lhs, source(named(index))) (ex.rhs, source(named(lastIndex))),
				in: relation(named(ex.lhs), gt, named(ex.rhs))
			),
			then: value(
				let((ex.vec, source(named(nums))) (ex.idx, source(named(lastIndex))), in: element(of: ex.vec, at: named(ex.idx)))
			),
			else: do(
				let(
					(ex.vec$1, source(named(nums)))
					(ex.idx$1, source(named(index)))
					(
						ex.elem,
						let(
							(
								ex.lhs$1,
								let(
									(ex.vec$2, source(named(nums)))
									(
										ex.idx$2,
										let(
											(ex.lhs$2, source(named(index))) (ex.rhs$2, source(constant(2))),
											in: binary(named(ex.lhs$2), sub, named(ex.rhs$2))
										)
									),
									in: element(of: ex.vec$2, at: named(ex.idx$2))
								)
							)
							(
								ex.rhs$1,
								let(
									(ex.vec$3, source(named(nums)))
									(
										ex.idx$3,
										let(
											(ex.lhs$3, source(named(index))) (ex.rhs$3, source(constant(1))),
											in: binary(named(ex.lhs$3), sub, named(ex.rhs$3))
										)
									),
									in: element(of: ex.vec$3, at: named(ex.idx$3))
								)
							),
							in: binary(named(ex.lhs$1), add, named(ex.rhs$1))
						)
					),
					in: setElement(of: ex.vec$1, at: named(ex.idx$1), to: named(ex.elem))
				),
				then: let(
					(
						ex.arg$5,
						let(
							(ex.lhs$4, source(named(index))) (ex.rhs$4, source(constant(1))),
							in: binary(named(ex.lhs$4), add, named(ex.rhs$4))
						)
					)
					(ex.arg$6, source(named(lastIndex)))
					(ex.arg$7, source(named(nums))),
					in: evaluate(function(recFib), named(ex.arg$5) named(ex.arg$6) named(ex.arg$7))
				)
			)
		)
	)
)