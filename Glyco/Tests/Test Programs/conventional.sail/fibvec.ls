(
	let((ex.arg, source(0)) (ex.arg$1, source(1)), in: evaluate(function(fib), ex.arg ex.arg$1)),
	functions: (
		fib,
		takes: (first, s32, sealed: false) (second, s32, sealed: false),
		returns: s32,
		in: let(
			(ex.arg, source(2)) (ex.arg$1, source(29)) (ex.arg$2, vector(s32, count: 30)),
			in: evaluate(function(recFib), ex.arg ex.arg$1 ex.arg$2)
		)
	)
	(
		recFib,
		takes: (index, s32, sealed: false)
		(lastIndex, s32, sealed: false)
		(nums, cap(vector(of: s32, sealed: false)), sealed: false),
		returns: s32,
		in: if(
			let((ex.lhs, source(index)) (ex.rhs, source(lastIndex)), in: relation(ex.lhs, gt, ex.rhs)),
			then: value(let((ex.vec, source(nums)) (ex.idx, source(lastIndex)), in: element(of: ex.vec, at: ex.idx))),
			else: do(
				let(
					(ex.vec$1, source(nums))
					(ex.idx$1, source(index))
					(
						ex.elem,
						let(
							(
								ex.lhs$1,
								let(
									(ex.vec$2, source(nums))
									(
										ex.idx$2,
										let((ex.lhs$2, source(index)) (ex.rhs$2, source(2)), in: binary(ex.lhs$2, sub, ex.rhs$2))
									),
									in: element(of: ex.vec$2, at: ex.idx$2)
								)
							)
							(
								ex.rhs$1,
								let(
									(ex.vec$3, source(nums))
									(
										ex.idx$3,
										let((ex.lhs$3, source(index)) (ex.rhs$3, source(1)), in: binary(ex.lhs$3, sub, ex.rhs$3))
									),
									in: element(of: ex.vec$3, at: ex.idx$3)
								)
							),
							in: binary(ex.lhs$1, add, ex.rhs$1)
						)
					),
					in: setElement(of: ex.vec$1, at: ex.idx$1, to: ex.elem)
				),
				then: let(
					(ex.arg, let((ex.lhs$4, source(index)) (ex.rhs$4, source(1)), in: binary(ex.lhs$4, add, ex.rhs$4)))
					(ex.arg$1, source(lastIndex))
					(ex.arg$2, source(nums)),
					in: evaluate(function(recFib), ex.arg ex.arg$1 ex.arg$2)
				)
			)
		)
	)
)