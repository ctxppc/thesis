(
	let((even, function(l.even)) (odd, function(l.odd)), in: evaluate(even, 246)),
	functions: (
		l.even,
		takes: (n, s32, sealed: false),
		returns: s32,
		in: let(
			(even, function(l.even)) (odd, function(l.odd)),
			in: if(relation(n, le, 0), then: value(1), else: evaluate(odd, binary(n, sub, 1)))
		)
	)
	(
		l.odd,
		takes: (n, s32, sealed: false),
		returns: s32,
		in: let(
			(even, function(l.even)) (odd, function(l.odd)),
			in: if(relation(n, le, 0), then: value(0), else: evaluate(even, binary(n, sub, 1)))
		)
	)
)