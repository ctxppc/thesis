(
	value(
		let(
			(ob.seal, seal())
			(ob.Counter.init, source(function(l.anon)))
			(
				ob.Counter.increase.m,
				let((ex.cap, source(function(l.anon$1))) (ex.seal, source(named(ob.seal))), in: sealed(ex.cap, with: ex.seal))
			)
			(
				ob.Counter.getCount.m,
				let(
					(ex.cap$1, source(function(l.anon$2))) (ex.seal$1, source(named(ob.seal))),
					in: sealed(ex.cap$1, with: ex.seal$1)
				)
			),
			in: let(
				(
					counter,
					let(
						(ex.arg, source(constant(32))) (ex.f, source(named(ob.Counter.init))),
						in: evaluate(named(ex.f), named(ex.arg))
					)
				)
				(
					ignored,
					let(
						(ex.arg$1, source(named(counter))) (ex.f$1, source(named(ob.Counter.increase.m))),
						in: evaluate(named(ex.f$1), named(ex.arg$1))
					)
				)
				(
					ignored,
					let(
						(ex.arg$2, source(named(counter))) (ex.f$2, source(named(ob.Counter.increase.m))),
						in: evaluate(named(ex.f$2), named(ex.arg$2))
					)
				)
				(
					ignored,
					let(
						(ex.arg$3, source(named(counter))) (ex.f$3, source(named(ob.Counter.increase.m))),
						in: evaluate(named(ex.f$3), named(ex.arg$3))
					)
				),
				in: let(
					(ex.arg$4, source(named(counter))) (ex.f$4, source(named(ob.Counter.getCount.m))),
					in: evaluate(named(ex.f$4), named(ex.arg$4))
				)
			)
		)
	),
	functions: (
		l.anon,
		takes: (initialValue, s32(), sealed: false),
		returns: cap(record(((value, s32())), sealed: true)),
		in: value(
			let(
				(
					ex.cap$2,
					let(
						(self, record(((value, s32())))),
						in: do(
							let(
								(ex.rec, source(named(self))) (ex.val, source(named(initialValue))),
								in: setField(value, of: ex.rec, to: named(ex.val))
							),
							then: source(named(self))
						)
					)
				)
				(ex.seal$2, source(named(ob.seal))),
				in: sealed(ex.cap$2, with: ex.seal$2)
			)
		)
	)
	(
		l.anon$1,
		takes: (ob.self, cap(record(((value, s32())), sealed: true)), sealed: true),
		returns: s32(),
		in: let(
			(newCount, let((ex.rec$1, source(named(ob.self))), in: field(value, of: ex.rec$1))),
			in: do(
				let(
					(ex.rec$2, source(named(ob.self))) (ex.val$1, source(named(newCount))),
					in: setField(value, of: ex.rec$2, to: named(ex.val$1))
				),
				then: value(source(named(newCount)))
			)
		)
	)
	(
		l.anon$2,
		takes: (ob.self, cap(record(((value, s32())), sealed: true)), sealed: true),
		returns: s32(),
		in: value(let((ex.rec$3, source(named(ob.self))), in: field(value, of: ex.rec$3)))
	)
)