(
	value(
		let(
			(sumOfFirstAndSecond, function(l.anon)) (pi, vector(s32(), count: 3)),
			in: do(
				setElement(of: named(pi), at: constant(0), to: constant(3))
				setElement(of: named(pi), at: constant(1), to: constant(1))
				setElement(of: named(pi), at: constant(2), to: constant(4)),
				then: evaluate(named(sumOfFirstAndSecond), named(pi))
			)
		)
	),
	functions: (
		l.anon,
		takes: (sequence, cap(vector(of: s32(), sealed: false)), sealed: false),
		returns: s32(),
		in: value(
			binary(
				element(of: named(sequence), at: constant(0)),
				add,
				element(of: named(sequence), at: constant(1))
			)
		)
	)
)