(
	value(
		let(
			(ob.seal, seal)
			(
				ob.Counter.type,
				let(
					(ob.typeobj, record(((seal, cap(seal(sealed: false)))))),
					in: do(setField(seal, of: ob.typeobj, to: ob.seal), then: sealed(ob.typeobj, with: ob.seal))
				)
			)
			(ob.ob.Counter.Type.createObject.m, sealed(function(l.anon), with: ob.seal))
			(ob.Counter.increase.m, sealed(function(l.anon$1), with: ob.seal))
			(ob.Counter.getCount.m, sealed(function(l.anon$2), with: ob.seal)),
			in: let(
				(counter, evaluate(ob.ob.Counter.Type.createObject.m, ob.Counter.type 32))
				(ignored, evaluate(ob.Counter.increase.m, counter))
				(ignored, evaluate(ob.Counter.increase.m, counter))
				(ignored, evaluate(ob.Counter.increase.m, counter)),
				in: evaluate(ob.Counter.getCount.m, counter)
			)
		)
	),
	functions: (
		l.anon,
		takes: (ob.self, cap(record(((seal, cap(seal(sealed: false)))), sealed: true)), sealed: true)
		(initialValue, s32, sealed: false),
		returns: cap(record(((value, s32)), sealed: true)),
		in: let(
			(ob.seal, field(seal, of: ob.self)) (ob.self, record(((value, s32)))),
			in: do(setField(value, of: ob.self, to: initialValue), then: value(sealed(ob.self, with: ob.seal)))
		)
	)
	(
		l.anon$1,
		takes: (ob.self, cap(record(((value, s32)), sealed: true)), sealed: true),
		returns: s32,
		in: let(
			(newValue, binary(field(value, of: ob.self), add, 1)),
			in: do(setField(value, of: ob.self, to: newValue), then: value(newValue))
		)
	)
	(
		l.anon$2,
		takes: (ob.self, cap(record(((value, s32)), sealed: true)), sealed: true),
		returns: s32,
		in: value(field(value, of: ob.self))
	)
)