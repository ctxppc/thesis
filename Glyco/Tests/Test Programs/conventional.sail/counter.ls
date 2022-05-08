(
	value(
		let(
			(ob.tseal, seal)
			(ob.oseal, seal)
			(
				ob.Counter.type,
				let(
					(ob.typeobj, record(((seal, cap(seal(sealed: false)))))),
					in: do(
						let((ex.rec, source(ob.typeobj)) (ex.val, source(ob.oseal)), in: setField(seal, of: ex.rec, to: ex.val)),
						then: let((ex.cap, source(ob.typeobj)) (ex.seal, source(ob.tseal)), in: sealed(ex.cap, with: ex.seal))
					)
				)
			)
			(
				ob.ob.Counter.Type.createObject.m,
				let((ex.cap$1, source(function(l.anon))) (ex.seal$1, source(ob.tseal)), in: sealed(ex.cap$1, with: ex.seal$1))
			)
			(
				ob.Counter.increase.m,
				let((ex.cap$2, source(function(l.anon$1))) (ex.seal$2, source(ob.oseal)), in: sealed(ex.cap$2, with: ex.seal$2))
			)
			(
				ob.Counter.getCount.m,
				let((ex.cap$3, source(function(l.anon$2))) (ex.seal$3, source(ob.oseal)), in: sealed(ex.cap$3, with: ex.seal$3))
			),
			in: let(
				(
					counter,
					let(
						(ex.arg, source(ob.Counter.type)) (ex.arg$1, source(32)) (ex.f, source(ob.ob.Counter.Type.createObject.m)),
						in: evaluate(ex.f, ex.arg ex.arg$1)
					)
				)
				(ignored, let((ex.arg$2, source(counter)) (ex.f$1, source(ob.Counter.increase.m)), in: evaluate(ex.f$1, ex.arg$2)))
				(ignored, let((ex.arg$3, source(counter)) (ex.f$2, source(ob.Counter.increase.m)), in: evaluate(ex.f$2, ex.arg$3)))
				(ignored, let((ex.arg$4, source(counter)) (ex.f$3, source(ob.Counter.increase.m)), in: evaluate(ex.f$3, ex.arg$4))),
				in: let((ex.arg$5, source(counter)) (ex.f$4, source(ob.Counter.getCount.m)), in: evaluate(ex.f$4, ex.arg$5))
			)
		)
	),
	functions: (
		l.anon,
		takes: (ob.self, cap(record(((seal, cap(seal(sealed: false)))), sealed: true)), sealed: true)
		(initialValue, s32, sealed: false),
		returns: cap(record(((value, s32)), sealed: true)),
		in: let(
			(ob.seal, let((ex.rec$1, source(ob.self)), in: field(seal, of: ex.rec$1))) (ob.self, record(((value, s32)))),
			in: do(
				let((ex.rec$2, source(ob.self)) (ex.val$1, source(initialValue)), in: setField(value, of: ex.rec$2, to: ex.val$1)),
				then: value(let((ex.cap$4, source(ob.self)) (ex.seal$4, source(ob.seal)), in: sealed(ex.cap$4, with: ex.seal$4)))
			)
		)
	)
	(
		l.anon$1,
		takes: (ob.self, cap(record(((value, s32)), sealed: true)), sealed: true),
		returns: s32,
		in: let(
			(
				newValue,
				let(
					(ex.lhs, let((ex.rec$3, source(ob.self)), in: field(value, of: ex.rec$3))) (ex.rhs, source(1)),
					in: binary(ex.lhs, add, ex.rhs)
				)
			),
			in: do(
				let((ex.rec$4, source(ob.self)) (ex.val$2, source(newValue)), in: setField(value, of: ex.rec$4, to: ex.val$2)),
				then: value(source(newValue))
			)
		)
	)
	(
		l.anon$2,
		takes: (ob.self, cap(record(((value, s32)), sealed: true)), sealed: true),
		returns: s32,
		in: value(let((ex.rec$5, source(ob.self)), in: field(value, of: ex.rec$5)))
	)
)