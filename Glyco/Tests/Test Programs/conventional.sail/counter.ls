(
	value(
		let(
			(ob.seal, seal())
			(
				ob.Counter.type,
				let(
					(ob.typeobj, record(((seal, cap(seal(sealed: false)))))),
					in: do(
						let(
							(ex.rec, source(named(ob.typeobj))) (ex.val, source(named(ob.seal))),
							in: setField(seal, of: ex.rec, to: named(ex.val))
						),
						then: let(
							(ex.cap, source(named(ob.typeobj))) (ex.seal, source(named(ob.seal))),
							in: sealed(ex.cap, with: ex.seal)
						)
					)
				)
			)
			(
				ob.ob.Counter.Type.createObject.m,
				let(
					(ex.cap$1, source(function(l.anon))) (ex.seal$1, source(named(ob.seal))),
					in: sealed(ex.cap$1, with: ex.seal$1)
				)
			)
			(
				ob.Counter.increase.m,
				let(
					(ex.cap$2, source(function(l.anon$1))) (ex.seal$2, source(named(ob.seal))),
					in: sealed(ex.cap$2, with: ex.seal$2)
				)
			)
			(
				ob.Counter.getCount.m,
				let(
					(ex.cap$3, source(function(l.anon$2))) (ex.seal$3, source(named(ob.seal))),
					in: sealed(ex.cap$3, with: ex.seal$3)
				)
			),
			in: let(
				(
					counter,
					let(
						(ex.arg, source(named(ob.Counter.type))) (ex.arg$1, source(constant(32))) (ex.f, source(named(ob.ob.Counter.Type.createObject.m))),
						in: evaluate(named(ex.f), named(ex.arg) named(ex.arg$1))
					)
				)
				(
					ignored,
					let(
						(ex.arg$2, source(named(counter))) (ex.f$1, source(named(ob.Counter.increase.m))),
						in: evaluate(named(ex.f$1), named(ex.arg$2))
					)
				)
				(
					ignored,
					let(
						(ex.arg$3, source(named(counter))) (ex.f$2, source(named(ob.Counter.increase.m))),
						in: evaluate(named(ex.f$2), named(ex.arg$3))
					)
				)
				(
					ignored,
					let(
						(ex.arg$4, source(named(counter))) (ex.f$3, source(named(ob.Counter.increase.m))),
						in: evaluate(named(ex.f$3), named(ex.arg$4))
					)
				),
				in: let(
					(ex.arg$5, source(named(counter))) (ex.f$4, source(named(ob.Counter.getCount.m))),
					in: evaluate(named(ex.f$4), named(ex.arg$5))
				)
			)
		)
	),
	functions: (
		l.anon,
		takes: (ob.self, cap(record(((seal, cap(seal(sealed: false)))), sealed: true)), sealed: true)
		(initialValue, s32(), sealed: false),
		returns: cap(record(((value, s32())), sealed: true)),
		in: let(
			(ob.newobj, record(((value, s32())))) (ob.seal, let((ex.rec$1, source(named(ob.self))), in: field(seal, of: ex.rec$1))),
			in: do(
				let(
					(ex.rec$2, source(named(ob.self))) (ex.val$1, source(named(initialValue))),
					in: setField(value, of: ex.rec$2, to: named(ex.val$1))
				),
				then: value(
					let(
						(ex.cap$4, source(named(ob.newobj))) (ex.seal$4, source(named(ob.seal))),
						in: sealed(ex.cap$4, with: ex.seal$4)
					)
				)
			)
		)
	)
	(
		l.anon$1,
		takes: (ob.self, cap(record(((value, s32())), sealed: true)), sealed: true),
		returns: s32(),
		in: let(
			(newCount, let((ex.rec$3, source(named(ob.self))), in: field(value, of: ex.rec$3))),
			in: do(
				let(
					(ex.rec$4, source(named(ob.self))) (ex.val$2, source(named(newCount))),
					in: setField(value, of: ex.rec$4, to: named(ex.val$2))
				),
				then: value(source(named(newCount)))
			)
		)
	)
	(
		l.anon$2,
		takes: (ob.self, cap(record(((value, s32())), sealed: true)), sealed: true),
		returns: s32(),
		in: value(let((ex.rec$5, source(named(ob.self))), in: field(value, of: ex.rec$5)))
	)
)