(
	value(
		let(
			(sumOfFirstAndSecond, function(l.anon)) (pi, vector(s32, count: 3)),
			in: do(
				setElement(of: pi, at: 0, to: 3)
				setElement(of: pi, at: 1, to: 1)
				setElement(of: pi, at: 2, to: 4),
				then: evaluate(sumOfFirstAndSecond, pi)
			)
		)
	),
	functions: (
		l.anon,
		takes: (sequence, cap(vector(of: s32, sealed: false)), sealed: false),
		returns: s32,
		in: value(binary(element(of: sequence, at: 0), add, element(of: sequence, at: 1)))
	)
)