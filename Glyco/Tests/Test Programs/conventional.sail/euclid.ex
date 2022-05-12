(
	evaluate(function(gcd), 20 50),
	functions: (
		gcd,
		takes: (a, s32, sealed: false) (b, s32, sealed: false),
		returns: s32,
		in: if(
			relation(a, eq, b),
			then: value(a),
			else: if(
				relation(a, gt, b),
				then: evaluate(function(gcd), binary(a, sub, b) b),
				else: evaluate(function(gcd), a binary(b, sub, a))
			)
		)
	)
)
