(
	value(
		let(
			(ob.seal, seal())
			(
				ob.Counter.type,
				let(
					(ob.typeobj, record(((seal, cap(seal(sealed: false)))))),
					in: do(
						setField(seal, of: named(ob.typeobj), to: named(ob.seal)),
						then: sealed(named(ob.typeobj), with: named(ob.seal))
					)
				)
			)
			(ob.ob.Counter.Type.createObject.m, sealed(function(l.anon), with: named(ob.seal)))
			(ob.Counter.increase.m, sealed(function(l.anon$1), with: named(ob.seal)))
			(ob.Counter.getCount.m, sealed(function(l.anon$2), with: named(ob.seal))),
			in: let(
				(counter, evaluate(named(ob.ob.Counter.Type.createObject.m), named(ob.Counter.type) constant(32)))
				(ignored, evaluate(named(ob.Counter.increase.m), named(counter)))
				(ignored, evaluate(named(ob.Counter.increase.m), named(counter)))
				(ignored, evaluate(named(ob.Counter.increase.m), named(counter))),
				in: evaluate(named(ob.Counter.getCount.m), named(counter))
			)
		)
	),
	functions: (
		l.anon,
		takes: (ob.self, cap(record(((seal, cap(seal(sealed: false)))), sealed: true)), sealed: true)
		(initialValue, s32(), sealed: false),
		returns: cap(record(((value, s32())), sealed: true)),
		in: let(
			(ob.seal, field(seal, of: named(ob.self))) (ob.self, record(((value, s32())))),
			in: do(
				setField(value, of: named(ob.self), to: named(initialValue)),
				then: value(sealed(named(ob.self), with: named(ob.seal)))
			)
		)
	)
	(
		l.anon$1,
		takes: (ob.self, cap(record(((value, s32())), sealed: true)), sealed: true),
		returns: s32(),
		in: let(
			(newCount, field(value, of: named(ob.self))),
			in: do(setField(value, of: named(ob.self), to: named(newCount)), then: value(named(newCount)))
		)
	)
	(
		l.anon$2,
		takes: (ob.self, cap(record(((value, s32())), sealed: true)), sealed: true),
		returns: s32(),
		in: value(field(value, of: named(ob.self)))
	)
)